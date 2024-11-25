// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/utilities/components/combo_box.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';

class CreateDirector extends StatefulWidget {
  const CreateDirector({super.key});

  @override
  State<CreateDirector> createState() => _CreateDirectorState();
}

class _CreateDirectorState extends State<CreateDirector> {
  TextEditingController nameController = TextEditingController();
  final List<String> careers = [
    'Ing. Sistemas',
    'Ing. Industrial',
    'Ing. Civil',
    'Lic. Administración',
    'Lic. Economía',
    'Medicina',
    'Arquitectura',
    'Derecho'
  ];
  String? selectedCareer;

  // Método para registrar en Firestore
  Future<void> registerDirector() async {
    if (nameController.text.isNotEmpty && selectedCareer != null) {
      try {
        await FirebaseFirestore.instance.collection('director').add({
          'name': nameController.text,
          'career': selectedCareer,
        });
        showAnimatedSnackBar(
          context,
          'Registo Exitoso',
          Colors.green,
          Icons.check,
        );
        // Limpiar los campos después de registrar
        nameController.clear();
        setState(() {
          selectedCareer = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, complete todos los campos'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Registrar Director',
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: mainColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // TextFormFieldModel(
                  //   controller: nameController,
                  //   textAttribute: 'Nombre',
                  // ),
                  const SizedBox(height: 20),
                  ComboBox(
                    itemsList: careers,
                    hintText: 'Carrera',
                    selectedValue: selectedCareer,
                    icon: const Icon(
                      Icons.school,
                      color: mainColor,
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCareer = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        registerDirector, // Llamada al método de registro
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                    ),
                    child: const Text(
                      'Registrar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
