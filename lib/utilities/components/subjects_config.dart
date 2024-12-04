import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';

class Subjects_Config extends StatefulWidget {
  final String idStudent;

  const Subjects_Config({
    super.key,
    required this.idStudent,
  });

  @override
  State<Subjects_Config> createState() => _Subjects_ConfigState();
}

class _Subjects_ConfigState extends State<Subjects_Config> {
  Map<String, bool> _selectedSubjects = {};
  String _searchQuery = "";
  int? _selectedSemester;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _initializeSelectedSubjects();
  }

  Future<void> _initializeSelectedSubjects() async {
    try {
      // Obtener el documento del estudiante desde Firestore
      final studentDoc =
          await instance.collection('student').doc(widget.idStudent).get();

      if (studentDoc.exists) {
        // Obtener las materias del estudiante
        List<dynamic> studentSubjects = studentDoc.data()?['subjects'] ?? [];

        // Inicializar el mapa con las materias seleccionadas
        setState(() {
          _selectedSubjects = {
            for (var subject in studentSubjects) subject: true
          };
        });
      }
    } catch (e) {
      print('Error al cargar las materias del estudiante: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Contenedor fijo para el buscador y el filtro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Text(
                'Selecciona tus Materias',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                  fontSize: 25,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors
              .white, // Fondo para que contraste con el contenido scrollable
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6D8586),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8F0B45),
                            width: 1,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: mainColor,
                          size: 20,
                        ),
                        hintText: 'Buscar Materia',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery =
                              value.toLowerCase(); // Actualiza la búsqueda
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _showSemesterBottomSheet,
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: mainColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Expandable ScrollView para las materias
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: instance.collection('subjects').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error al cargar las materias'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No hay materias disponibles'),
                );
              }

              // Procesar los datos obtenidos de Firestore
              List<String> subjects = [];
              try {
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;

                  // Filtrar por semestre
                  if (_selectedSemester != null &&
                      data['semester'] != _selectedSemester) {
                    continue;
                  }

                  // Obtener materias
                  List<dynamic> subjectsField = data['subjects'] ?? [];
                  subjects.addAll(subjectsField.map((s) => s.toString()));
                }
              } catch (e) {
                print('Error al procesar documentos: $e');
              }

              // Aplicar filtro de búsqueda
              subjects = subjects
                  .where(
                      (subject) => subject.toLowerCase().contains(_searchQuery))
                  .toList();

              // Inicializa el estado de selección si aún no se ha hecho
              for (var subject in subjects) {
                _selectedSubjects.putIfAbsent(subject, () => false);
              }

              return _subjectItems(subjects);
            },
          ),
        ),
        // Botón fijo
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 20,
              ),
            ),
            onPressed: _saveSubjects,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Guardar Materias',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSubjects() async {
    setState(() {
      _isLoading = true;
    });
    final selected = _selectedSubjects.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    try {
      await instance
          .collection('student')
          .doc(widget.idStudent)
          .update({'subjects': selected});
      showAnimatedSnackBar(
        context,
        'Materias Guardadas Correctamente',
        Colors.green,
        Icons.check,
      );
    } catch (e) {
      showAnimatedSnackBar(context, e.toString(), Colors.red, Icons.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ListView _subjectItems(List<String> subjects) {
    return ListView.builder(
      key: PageStorageKey('subjectsList'),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return CheckboxListTile(
          title: Text(
            subject,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          activeColor: mainColor,
          value: _selectedSubjects[subject],
          onChanged: (bool? value) {
            setState(() {
              _selectedSubjects[subject] = value ?? false;
            });
          },
        );
      },
    );
  }

  void _showSemesterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView.builder(
            itemCount: 7, // 6 semestres + 1 opción "Todos"
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text("Todos"),
                  onTap: () {
                    setState(() {
                      _selectedSemester = null; // Resetea el filtro de semestre
                    });
                    Navigator.pop(context); // Cierra el BottomSheet
                  },
                );
              }
              int semester = index; // Ajusta el índice para los semestres
              return ListTile(
                title: Text("Semestre $semester"),
                onTap: () {
                  setState(() {
                    _selectedSemester = semester;
                  });
                  Navigator.pop(context); // Cierra el BottomSheet
                },
              );
            },
          ),
        );
      },
    );
  }
}
