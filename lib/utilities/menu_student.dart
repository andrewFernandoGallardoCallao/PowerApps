import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/subjects_config.dart';
import 'package:power_apps_flutter/utilities/create_request.dart'; // Asegúrate de que este archivo esté correctamente importado
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StudentMainMenu extends StatefulWidget {
  final Student student;

  const StudentMainMenu({
    super.key,
    required this.student,
  });

  @override
  StudentMainMenuState createState() => StudentMainMenuState();
}

class StudentMainMenuState extends State<StudentMainMenu> {
  int _currentIndex = 0;
  final List<String> _titles = [
    'Solicitudes',
    'Crear Solicitud',
    'Configuración Materias',
  ];

  List<Widget> _getPages() {
    return [
      _streamRequest(),
      CreateRequest(student: widget.student),
      Subjects_Config(
        idStudent: widget.student.id,
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Método para obtener las solicitudes del usuario
  StreamBuilder<QuerySnapshot<Object?>> _streamRequest() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUserRequests(),
      builder: (context, snapshot) {
        // Manejo de estados del snapshot
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Ocurrió un error al cargar las solicitudes.'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No tienes solicitudes registradas.'),
          );
        }

        // Construimos la lista con los datos del snapshot
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Solicitudes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      fontSize: 25,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.filter_list_outlined,
                          color: mainColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final requests = snapshot.data!.docs;
                          await generateReport(requests);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Reporte PDF descargado.')),
                          );
                        },
                        icon: const Icon(
                          Icons.download,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Construye las tarjetas
            ..._getRequest(snapshot), // Uso del operador "spread"
          ],
        );
      },
    );
  }

  List<Widget> _getRequest(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return snapshot.data!.docs.map((doc) {
      // Validación para evitar datos nulos
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return const SizedBox(); // Retorna un widget vacío si no hay datos
      }

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Razón: ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "${data['reason'] ?? 'Sin razón'}", // Manejo de campos nulos
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Fecha: ${_formatDate(data['fecha'] ?? '')}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "Estado: ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "${data['estado'] ?? 'Desconocido'}",
                    style: TextStyle(
                      fontSize: 14,
                      color: getColor(data['estado'] ?? ''),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Formatea la fecha
    } catch (e) {
      return 'Fecha inválida'; // Manejo de errores
    }
  }

// Método para generar y descargar el reporte PDF
  Future<void> generateReport(
      List<QueryDocumentSnapshot<Object?>> requests) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>?;
              if (data == null) return pw.SizedBox();
              return pw.Container(
                margin: const pw.EdgeInsets.all(8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.amber),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Razón: ${data['reason'] ?? 'Sin razón'}"),
                    pw.SizedBox(height: 4),
                    pw.Text("Fecha: ${data['fecha'] ?? 'Fecha inválida'}"),
                    pw.SizedBox(height: 4),
                    pw.Text("Estado: ${data['estado'] ?? 'Desconocido'}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/reporte.pdf");
    await file.writeAsBytes(await pdf.save());
  }

  Color getColor(String estadoPermiso) {
    switch (estadoPermiso) {
      case 'Aprobado':
        return Colors.green;
      case 'Reprobado':
        return Colors.red;
      case 'Pendiente':
        return Colors.yellow[800]!;
      default:
        return Colors.black;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserRequests() {
    final studentRef = instance.collection('student').doc(widget.student.id);

    return FirebaseFirestore.instance
        .collection('request')
        .where('userReference', isEqualTo: studentRef)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título del AppBar
              Text(
                _titles[_currentIndex],
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Verificación del tamaño de la pantalla
              sizeScreen.width > 600
                  ? Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 255, 250, 250),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.student.name,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.student.mail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.student.career,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _signOut,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton<int>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: sizeScreen.width * 0.06,
                          ),
                          onSelected: (int selected) {
                            if (selected == 0) {
                              _signOut();
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.student.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                widget.student.mail,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                widget.student.career,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.exit_to_app,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Salir",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _getPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Crear Solicitud',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subject),
            label: 'Materias',
          )
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/Login'); // Redirige a la pantalla de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
