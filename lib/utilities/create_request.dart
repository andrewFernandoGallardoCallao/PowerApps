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
import 'package:power_apps_flutter/utilities/components/text_form_field_model.dart';
import 'package:power_apps_flutter/utilities/components/toast.dart';
import 'package:power_apps_flutter/utilities/components/progressbar.dart';

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
  bool isLoading = false;
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

  bool validateForm() {
    if (selectedSubject == null) {
      showAnimatedSnackBar(
        context,
        'Por favor, seleccione una materia',
        Colors.red,
        Icons.error,
      );
      return false;
    }

    if (selectedDate == null) {
      showAnimatedSnackBar(
        context,
        'Por favor, seleccione una fecha',
        Colors.red,
        Icons.error,
      );
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

  /// Subir archivo y agregar la solicitud.
  Future<void> addRequest() async {
    if (!validateForm()) {
      return;
    }

    // ignore: duplicate_ignore
    try {
      ProgressBar.showProgressDialog(context, "Creando Solicitud");
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
        'fecha': selectedDate?.toIso8601String() ?? 'Fecha no seleccionada',
        'userReference': reference
      });

      showAnimatedSnackBar(
        context,
        'Solicitud Creada',
        Colors.green,
        Icons.check,
      );
    } catch (e) {
      showAnimatedSnackBar(context, e.toString(), Colors.red, Icons.error);
    } finally {
      ProgressBar.closeProgressDialog(context);
      clearFields();
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
      _reasonController.clear();
      selectedSubject = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
    return Center(
      child: Form(
        key: _formKey,
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
                    TextFormFieldModel(
                      controller: _reasonController,
                      textAttribute: 'la razon de la solicitud',
                      icon: const Icon(
                        Icons.text_snippet_outlined,
                        color: mainColor,
                      ),
                      inputFormatter: const [],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la razon';
                        }
                        if (value.length > 51) {
                          return 'Maximo cantidad de caracteres 50';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ComboBox(
                      itemsList: subjects,
                      hintText: 'Materia',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fileNames.isNotEmpty) ...[
                          const Text(
                            'Archivos Seleccionados:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: fileNames.length,
                            itemBuilder: (context, index) {
                              final fileName = fileNames[index];
                              final fileType =
                                  fileName.split('.').last.toLowerCase();

                              // Verificar si es una imagen
                              if (['png', 'jpg', 'jpeg'].contains(fileType)) {
                                // Archivos de imagen
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.image,
                                          color: mainColor,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style:
                                                const TextStyle(fontSize: 16),
                                            overflow: TextOverflow
                                                .ellipsis, // Si el nombre es muy largo, se trunca
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              fileNames.removeAt(index);
                                              if (kIsWeb) {
                                                fileBytes.removeAt(index);
                                              } else {
                                                selectedFile =
                                                    null; // O eliminar de una lista si guardas múltiples archivos
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(), // Línea separadora opcional
                                  ],
                                );
                              } else {
                                // Archivos no imagen (PDF, DOCX)
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.insert_drive_file,
                                          color: mainColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          fileName,
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow
                                              .ellipsis, // Trunca nombres largos
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            fileNames.removeAt(index);
                                            fileUrls.removeAt(index);
                                            if (kIsWeb) {
                                              fileBytes.removeAt(index);
                                            } else {
                                              selectedFile =
                                                  null; // O eliminar de una lista si guardas múltiples archivos
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: selectFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: sizeScreen.width * 0.2,
                          vertical: 20,
                        ),
                      ),
                      child: const Text(
                        'Adjuntar Evidencia',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          addRequest();
                        } else {
                          print('Formulario no válido');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: sizeScreen.width * 0.2,
                          vertical: 20,
                        ),
                      ),
                      child: const Text(
                        'Enviar Solicitud',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
