import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/create_request.dart'; // Asegúrate de que este archivo esté correctamente importado
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';

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
    'Mis Solicitudes', // Título para la primera pestaña
    'Crear Solicitud', // Título para la segunda pestaña
    'Historial', // Título para la tercera pestaña
    'Perfil', // Título para la cuarta pestaña
  ];

  // Las páginas dentro del IndexedStack
  List<Widget> _getPages() {
    return [
      // Página de Solicitudes del Estudiante (índice 0)
      _streamRequest(),

      // Página de Crear Solicitud (índice 1)
      CreateRequest(student: widget.student), // Pasa el estudiante aquí

      // Página de Historial (índice 2)
      const Center(child: Text('Historial')),

      // Página de Perfil (índice 3)
      const Center(child: Text('Perfil')),
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
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_list_outlined,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _getRequest(snapshot),
            ),
          ],
        );
      },
    );
  }

  ListView _getRequest(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: snapshot.data!.docs.map((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

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
                const SizedBox(height: 8),
                Text(
                  "Fecha: ${_formatDate(data['fecha'])}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                // Text(
                //   "Teléfono: ${data['phone']}",
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.grey[600],
                //   ),
                // ),
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
                      "${data['estado']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: getColor(data['estado']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Formatea la fecha
    } catch (e) {
      return 'Fecha inválida'; // Manejo de errores
    }
  }

  Color getColor(String estadoPermiso) {
    switch (estadoPermiso) {
      case 'Aprobado':
        return Colors.green;
      case 'Cancelado':
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
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
                ],
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children:
            _getPages(), // Usamos _getPages() para cargar las vistas dinámicamente
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
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
