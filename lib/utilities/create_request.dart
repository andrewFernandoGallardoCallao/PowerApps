// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/combo_box.dart';
import 'package:power_apps_flutter/utilities/components/date_picker.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';
import 'package:power_apps_flutter/utilities/components/toast.dart';

class CreateRequest extends StatefulWidget {
  final Student student;

  const CreateRequest({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  CreateRequestState createState() => CreateRequestState();
}

class CreateRequestState extends State<CreateRequest> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String? selectedFileName;
  File? selectedFile;
  Uint8List? selectedBytes;
  String? fileUrl;
  DateTime? selectedDate;
  List<String> fileNames = [];
  List<String> fileUrls = [];
  List<Uint8List> fileBytes = [];

  List<String> subjects = [
    'Programacion 1',
    'Programación Web I',
    'SQA',
    'Base de Datos I'
  ];
  String? selectedSubject;

  /// Selección del archivo.
  Future<void> selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'docx'],
        allowMultiple: true, // Permitir selección múltiple
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          if (kIsWeb) {
            // En Web, guardamos los bytes y el nombre del archivo.
            fileBytes.add(file.bytes!);
            fileNames.add(file.name);
          } else {
            // En Móvil/Escritorio, obtenemos la ruta y el nombre.
            final path = file.path;
            if (path != null) {
              setState(() {
                selectedFile = File(path);
                fileNames.add(file.name);
              });
            }
          }
        }
        print('Archivos seleccionados: $fileNames');
      } else {
        print('No se seleccionaron archivos.');
      }
    } catch (e) {
      Toast.show(context, e.toString());
    }
  }

  /// Subir archivo y agregar la solicitud.
  Future<void> addRequest() async {
    if (fileNames.isEmpty) {
      print("Por favor, complete todos los campos.");
      return;
    }

    try {
      fileUrls.clear(); // Limpiar la lista de URLs antes de subir

      // Subir archivos uno por uno y almacenar sus URLs
      for (int i = 0; i < fileNames.length; i++) {
        String downloadUrl;
        if (kIsWeb) {
          downloadUrl = await uploadFileWeb(fileBytes[i], fileNames[i]);
        } else {
          downloadUrl = await uploadFileMobile(fileNames[i]);
        }
        fileUrls.add(downloadUrl); // Agregar la URL a la lista
      }
      DocumentReference reference =
          firestore.collection('student').doc(widget.student.id);
      // Guardar los datos en Firestore
      await firestore.collection('request').add({
        'evidence_urls': fileUrls, // Guardar la lista de URLs
        'evidence_names': fileNames, // Guardar la lista de nombres
        'estado': 'Pendiente',
        'fecha': selectedDate?.toIso8601String() ?? 'Fecha no seleccionada',
        'userReference': reference
      });

      showAnimatedSnackBar(context, 'Solicitud Creada', Colors.green);
      clearFields();
    } catch (e) {
      print("Error al enviar solicitud: $e");
    }
  }

  /// Subida del archivo en Web.
  Future<String> uploadFileWeb(Uint8List bytes, String fileName) async {
    final storageRef = storage.ref().child('evidences/$fileName');
    final metadata = SettableMetadata(contentType: _getMimeType(fileName));
    await storageRef.putData(bytes, metadata);
    return await storageRef.getDownloadURL();
  }

  /// Subida del archivo en Móvil/Escritorio.
  Future<String> uploadFileMobile(String fileName) async {
    final storageRef = storage.ref().child('evidences/$fileName');
    await storageRef.putFile(selectedFile!);
    return await storageRef.getDownloadURL();
  }

  /// Obtener el tipo MIME del archivo.
  String _getMimeType(String fileName) {
    if (fileName.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (fileName.endsWith('.pdf')) {
      return 'application/pdf';
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (fileName.endsWith('.png')) {
      return 'image/png';
    } else {
      return 'application/octet-stream';
    }
  }

  /// Limpiar los campos después de enviar la solicitud.
  void clearFields() {
    setState(() {
      selectedFile = null;
      selectedBytes = null;
      selectedFileName = null;
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 40,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ComboBox(
                    itemsList: subjects,
                    hintText: 'materia',
                    icon: const Icon(
                      Icons.auto_stories_outlined,
                      color: mainColor,
                    ),
                    selectedValue: selectedSubject,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSubject = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SimpleDatePickerFormField(
                    onDateSelected: (DateTime? date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectFile,
                    child: const Text('Adjuntar Evidencia'),
                  ),
                  if (selectedFileName != null)
                    Text('Archivo seleccionado: $selectedFileName'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addRequest,
                    child: const Text('Enviar Solicitud'),
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
