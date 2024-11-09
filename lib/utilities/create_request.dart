import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_apps_flutter/utilities/components/combo_box.dart';
import 'package:power_apps_flutter/utilities/components/date_picker.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';
import 'package:power_apps_flutter/utilities/components/text_form_field_model.dart';
import 'package:power_apps_flutter/utilities/components/toast.dart';

class CreateRequest extends StatefulWidget {
  const CreateRequest({Key? key}) : super(key: key);

  @override
  CreateRequestState createState() => CreateRequestState();
}

class CreateRequestState extends State<CreateRequest> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ciController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cellPhonelController = TextEditingController();

  String? selectedCarrera;
  String? selectedFileName;
  File? selectedFile;
  Uint8List? selectedBytes;
  String? fileUrl;
  DateTime? selectedDate;
  List<String> fileNames = [];
  List<String> fileUrls = [];
  List<Uint8List> fileBytes = [];

  List<String> carreras = ['ISI', 'MDC', 'UI', 'Arquitectura'];

  /// Selección del archivo.
  Future<void> selectFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'docx'],
      allowMultiple: true,  // Permitir selección múltiple
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
  if (nameController.text.isEmpty ||
      ciController.text.isEmpty ||
      selectedCarrera == null ||
      fileNames.isEmpty) {
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

    // Guardar los datos en Firestore
    await firestore.collection('request').add({
      'name': nameController.text,
      'ci': ciController.text,
      'phone': phoneController.text,
      'cell': cellPhonelController.text,
      'carrera': selectedCarrera,
      'evidence_urls': fileUrls,  // Guardar la lista de URLs
      'evidence_names': fileNames,  // Guardar la lista de nombres
      'estado': 'Pendiente',
      'fecha': selectedDate?.toIso8601String() ?? 'Fecha no seleccionada',
    });

    showAnimatedSnackBar(context, 'Solicitud Creada');
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
    nameController.clear();
    ciController.clear();
    phoneController.clear();
    cellPhonelController.clear();
    setState(() {
      selectedFile = null;
      selectedBytes = null;
      selectedFileName = null;
      selectedCarrera = null;
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, size: 25),
        title: const Text(
          'Crear Solicitud',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(96, 36, 68, 1),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormFieldModel(
                      controller: nameController,
                      textAttribute: 'Nombre',
                      inputFormatter: [
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      icon: const Icon(
                        Icons.person,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldModel(
                      controller: ciController,
                      textAttribute: 'Ci/Pasaporte',
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      icon: const Icon(
                        Icons.badge,
                        color: mainColor,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldModel(
                      controller: phoneController,
                      textAttribute: 'Teléfono',
                      keyboardType: TextInputType.phone,
                      icon: const Icon(
                        Icons.phone,
                        color: mainColor,
                      ),
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormFieldModel(
                      controller: cellPhonelController,
                      textAttribute: 'Numero de Celular',
                      icon: const Icon(
                        Icons.phone_android_outlined,
                        color: mainColor,
                      ),
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
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
                    ComboBox(
                      itemsList: carreras,
                      hintText: 'Carrera',
                      selectedValue: selectedCarrera,
                      icon: const Icon(
                        Icons.school,
                        color: mainColor,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCarrera = newValue;
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
      ),
    );
  }
}
