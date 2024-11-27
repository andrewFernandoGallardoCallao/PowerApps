import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/combo_box.dart';
import 'package:power_apps_flutter/utilities/components/date_picker.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';
import 'package:power_apps_flutter/utilities/components/text_form_field_model.dart';
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
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedFileName;
  File? selectedFile;
  Uint8List? selectedBytes;
  String? fileUrl;
  DateTime? selectedDate;
  List<String> fileNames = [];
  List<String> fileUrls = [];
  List<Uint8List> fileBytes = [];

  List<String> subjects = [];
  String? selectedSubject;

  /// Cargar las materias desde Firestore.
  Future<void> loadSubjects() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('docente').get();
      List<String> subjectList = [];

      for (var doc in querySnapshot.docs) {
        // Verificar si el campo 'materias' es un array
        List<dynamic> materias = doc['materias'] ??
            []; // Usar un valor predeterminado vacío si no existe
        for (var materia in materias) {
          // Añadir cada materia del array a la lista
          subjectList.add(materia);
        }
      }

      setState(() {
        subjects = subjectList; // Actualizar la lista de materias en la UI
      });
    } catch (e) {
      Toast.show(context, 'Error al cargar las materias: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadSubjects(); // Cargar las materias al iniciar la pantalla
  }

  /// Selección del archivo.
  Future<void> selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'docx'],
        allowMultiple: true, // Permitir selección múltiple
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
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
        });
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
    if (!validateForm()) {
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
        'reason': _reasonController.text,
        'fecha': selectedDate!.toIso8601String(),
        'userReference': reference,
        'subject': selectedSubject,
      });

      // ignore: use_build_context_synchronously
      showAnimatedSnackBar(
        context,
        'Solicitud Creada',
        Colors.green,
        Icons.check,
      );
      clearFields();
    } catch (e) {
      print("Error al enviar solicitud: $e");
    }
  }

  bool validateForm() {
    if (selectedSubject == null) {
      showAnimatedSnackBar(context, 'Por favor, seleccione una materia',
          Colors.red, Icons.error);
      return false;
    }

    if (selectedDate == null) {
      showAnimatedSnackBar(
          context, 'Por favor, seleccione una fecha', Colors.red, Icons.error);
      return false;
    }

    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    if (selectedDate!.isAfter(now)) {
      showAnimatedSnackBar(
        context,
        'La fecha no puede ser futura',
        Colors.red,
        Icons.error,
      );
      return false;
    }

    if (selectedDate!.isBefore(threeDaysAgo)) {
      showAnimatedSnackBar(
        context,
        'La fecha no puede ser más de 3 días en el pasado',
        Colors.red,
        Icons.error,
      );
      return false;
    }

    if (fileNames.isEmpty) {
      showAnimatedSnackBar(
        context,
        'Por favor, adjunte al menos un archivo',
        Colors.red,
        Icons.error,
      );
      return false;
    }

    return true;
  }

  /// Subida del archivo en Web.
  Future<String> uploadFileWeb(Uint8List bytes, String fileName) async {
    final storageRef = storage.ref().child('evidences/$fileName');
    final metadata = SettableMetadata(contentType: _getMimeType(fileName));
    await storageRef.putData(bytes, metadata);
    return await storageRef.getDownloadURL();
  }

  Future<String> uploadFileMobile(String fileName) async {
    final storageRef = storage.ref().child('evidences/$fileName');
    await storageRef.putFile(selectedFile!);
    return await storageRef.getDownloadURL();
  }

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

  void clearFields() {
    setState(() {
      selectedFile = null;
      selectedBytes = null;
      selectedFileName = null;
      selectedDate = null;
      selectedSubject = null;
      fileNames.clear();
      fileBytes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
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
