import 'package:flutter/material.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectConfiguration extends StatefulWidget {
  final Student student;

  const SubjectConfiguration({Key? key, required this.student}) : super(key: key);

  @override
  _SubjectConfigurationState createState() => _SubjectConfigurationState();
}

class _SubjectConfigurationState extends State<SubjectConfiguration> {
  int selectedSemester = 1;
  List<String> currentSubjects = [];
  List<String> selectedSubjects = [];
  List<int> availableSemesters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
  try {
    //print('Carrera del estudiante: "${widget.student.career}"');
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('career', isEqualTo: '"${widget.student.career}"')
        .get();

    //print('Documentos encontrados con filtro: ${snapshot.docs.length}');

    final semesters = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['semester'] as int)
        .toSet()
        .toList()
      ..sort();

    //print('Semestres disponibles: $semesters');
    if (mounted) {
      setState(() {
        availableSemesters = semesters;
        isLoading = false;
        if (semesters.isNotEmpty) {
          _updateSubjectsForSemester(semesters.first);
        }
      });
    }
  } catch (e) {
    //print('Error al cargar semestres: $e');
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  Future<void> _updateSubjectsForSemester(int semester) async {
  try {
    //print('Actualizando materias para semestre: $semester');
    
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('career', isEqualTo: '"${widget.student.career}"')
        .where('semester', isEqualTo: semester)
        .get();

    //print('Documentos encontrados para semestre $semester: ${snapshot.docs.length}');

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      final subjects = List<String>.from(data['subjects'] ?? []);

      //print('Materias encontradas: $subjects');

      if (mounted) {
        setState(() {
          selectedSemester = semester;
          currentSubjects = subjects;
          selectedSubjects.clear();
        });
      }
    }
  } catch (e) {
    //print('Error al actualizar materias: $e');
  }
}

  void _toggleSubject(String subject) {
  setState(() {
    if (selectedSubjects.contains(subject)) {
      selectedSubjects.remove(subject);
    } else if (selectedSubjects.length < 7) {
      selectedSubjects.add(subject);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes seleccionar hasta 7 materias.')),
      );
    }
  });
}


  void _updateFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('student')
          .doc(widget.student.id)
          .update({
        'semester': selectedSemester,
        'selectedSubjects': selectedSubjects,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materias actualizadas con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar materias: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de Semestre',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Carrera: ${widget.student.career}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selecciona tu semestre:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (availableSemesters.isEmpty)
                    const Text('No hay semestres disponibles')
                  else
                    DropdownButton<int>(
                      value: selectedSemester,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          _updateSubjectsForSemester(newValue);
                        }
                      },
                      items: availableSemesters.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('Semestre $value'),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selecciona tus materias:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: currentSubjects.isEmpty
                        ? const Center(child: Text('No hay materias disponibles'))
                        : ListView.builder(
                            itemCount: currentSubjects.length,
                            itemBuilder: (context, index) {
                              final subject = currentSubjects[index];
                              return CheckboxListTile(
                                title: Text(subject),
                                value: selectedSubjects.contains(subject),
                                onChanged: (_) => _toggleSubject(subject),
                                activeColor: mainColor,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateFirestore,
                      child: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}