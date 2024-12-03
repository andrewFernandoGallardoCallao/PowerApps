import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

class Subjects_Config extends StatefulWidget {
  const Subjects_Config({super.key});

  @override
  State<Subjects_Config> createState() => _Subjects_ConfigState();
}

class _Subjects_ConfigState extends State<Subjects_Config> {
  Map<String, bool> _selectedSubjects = {};
  String _searchQuery = "";
  int? _selectedSemester;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        // Campo de búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Buscar materia",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Icons.search, color: mainColor),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase(); // Actualiza la búsqueda
              });
            },
          ),
        ),
        // Dropdown para filtrar por semestre
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: DropdownButton<int>(
            isExpanded: true,
            hint: const Text("Filtrar por semestre"),
            value: _selectedSemester,
            items: List.generate(
              6,
              (index) => DropdownMenuItem(
                value: (index + 1),
                child: Text("Semestre ${index + 1}"),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedSemester = value; // Actualiza el semestre seleccionado
              });
            },
          ),
        ),
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

              return ListView.builder(
                itemCount: subjects.length, // Cantidad de materias
                itemBuilder: (context, index) {
                  final subject = subjects[index]; // Materia actual
                  return CheckboxListTile(
                    title: Text(subject),
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
            },
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 20,
            ),
          ),
          child: const Text(
            'Guardar Materias',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            // Acción al presionar el botón (por ejemplo, guardar selección)
            final selected = _selectedSubjects.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();
            print("Materias seleccionadas: $selected");
          },
        ),
      ],
    );
  }
}
