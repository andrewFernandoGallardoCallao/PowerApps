import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/create_request.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/subject_configuration.dart'; // Asegúrate de crear este archivo

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
    'Mis Solicitudes',
    'Crear Solicitud',
    'Configurar Materias',
    'Historial',
    'Perfil',
  ];

  List<Widget> _getPages() {
    return [
      _streamRequest(),
      CreateRequest(student: widget.student),
      SubjectConfiguration(student: widget.student), // Nueva página
      const Center(child: Text('Historial')),
      const Center(child: Text('Perfil')),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  StreamBuilder<QuerySnapshot<Object?>> _streamRequest() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUserRequests(),
      builder: (context, snapshot) {
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
            ..._getRequest(snapshot),
          ],
        );
      },
    );
  }

  List<Widget> _getRequest(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return snapshot.data!.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return const SizedBox();
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
                    "${data['reason'] ?? 'Sin razón'}",
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
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Fecha inválida';
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
    final Size sizeScreen = MediaQuery.sizeOf(context);
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
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: sizeScreen.width * 0.04,
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
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                      size: sizeScreen.width * 0.04,
                    ),
                    onPressed: () {
                      _signOut();
                    },
                  ),
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
            icon: Icon(Icons.settings),
            label: 'Configurar Materias',
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/Login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}

