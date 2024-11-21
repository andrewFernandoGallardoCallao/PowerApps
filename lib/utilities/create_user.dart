// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:power_apps_flutter/models/student_dto.dart';
import 'package:power_apps_flutter/utilities/components/combo_box.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';
import 'package:power_apps_flutter/utilities/components/text_form_field_model.dart';
import 'package:power_apps_flutter/utilities/components/combo_box.dart';  // Importar ComboBox

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State createState() {
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cellPhonelController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  String? _selectedCareer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: mainColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'lib/assets/img/logoUnivalle.png',
                height: sizeScreen.height / 3,
              ),
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.all(30),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Registrarse",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      formulario(),
                      const SizedBox(height: 20),
                      btnSignUp(sizeScreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const SizedBox(height: 12),
          buildPassword(),
          const SizedBox(height: 12),
          TextFormFieldModel(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textAttribute: 'su Nombre',
            icon: const Icon(Icons.text_fields, color: mainColor),
            inputFormatter: const [],
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Porfavor ingrese su Nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormFieldModel(
            controller: _ciController,
            keyboardType: TextInputType.number,
            textAttribute: 'su CI',
            icon: const Icon(Icons.badge, color: mainColor),
            inputFormatter: const [],
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Porfavor ingrese su celular';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormFieldModel(
            controller: _cellPhonelController,
            keyboardType: TextInputType.phone,
            textAttribute: 'su Celular',
            icon: const Icon(Icons.phone_android, color: mainColor),
            inputFormatter: [FilteringTextInputFormatter.digitsOnly],
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Porfavor ingrese su celular';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormFieldModel(
            controller: _phoneController,
            textAttribute: 'su Telefono',
            icon: const Icon(Icons.phone, color: mainColor),
            inputFormatter: [FilteringTextInputFormatter.singleLineFormatter],
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su telefono';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          ComboBox(
            itemsList: const [
              'Ing. Sistemas',
            ],
            hintText: 'carrera',
            icon: const Icon(
              Icons.school,
              color: mainColor,
            ),
            selectedValue: _selectedCareer,
            onChanged: (newValue) {
              setState(() {
                _selectedCareer = newValue;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormFieldModel(
      controller: _emailController,
      textAttribute: 'su email',
      icon: const Icon(
        Icons.person,
        color: mainColor,
      ),
      inputFormatter: const [],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su correo';
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormFieldModel(
      controller: _passwordController,
      textAttribute: 'su Contraseña',
      icon: const Icon(
        Icons.lock,
        color: mainColor,
      ),
      inputFormatter: const [],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una contraseña';
        }
        final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
        if (!passwordRegExp.hasMatch(value)) {
          return 'La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un carácter especial';
        }
        return null;
      },
    );
  }

  Widget buildCareerDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCareer,
      hint: Text('Seleccione su carrera'),
      items: <String>[
        'Arquitectura',
        'Economía',
        'Ing. Sistemas',
        'Ing. Civil',
        'Medicina',
        'Derecho'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Color(0xFF950A67))),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCareer = newValue;
        });
      },
        validator: (value) {
        if (value == null) {
          return 'Por favor seleccione una carrera';
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Color(0xFF950A67)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Color(0xFF6D8586)),
        ),
      ),
    );
  }

  Widget btnSignUp(Size sizeScreen) {
    return ElevatedButton(
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
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          String email = _emailController.text;
          String password = _passwordController.text;
          String name = _nameController.text;
          if (email.isNotEmpty &&
              password.isNotEmpty &&
              _selectedCareer != null) {
            UserCredential? credenciales = await createU(
              StudentDto(
                name: name,
                password: password,
                email: email,
                career: _selectedCareer,
              ),
              context,
            );
            if (credenciales != null) {
              if (credenciales.user != null) {
                await credenciales.user!.sendEmailVerification();
                Navigator.of(context).pop();
              }
            }
          }
        }
      },
      child: Text("Registrarse", style: TextStyle(color: Colors.white)),
    );
  }
}

// Función para crear el usuario en Firestore y Firebase Authentication
Future<UserCredential?> createU(
    StudentDto student, BuildContext context) async {
  try {
    // Verificar si el correo ya existe en Firestore
    QuerySnapshot existingUser = await instance
        .collection('student')
        .where('mail', isEqualTo: student.email)
        .get();

    if (existingUser.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo ya está registrado.')),
      );
      return null;
    }

    // Si no existe en Firestore, proceder con Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: student.email,
      password: student.password,
    );

    // Guardar correo, carrera y contraseña en Firestore
    await FirebaseFirestore.instance
        .collection('student')
        .doc(userCredential.user?.uid)
        .set({
      'name': student.name,
      'mail': student.email,
      'password': student.password, // encriptar la contraseña
      'career': student.career,
      'type': 'Student'
    });

    return userCredential;
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'email-already-in-use') {
      errorMessage = 'El correo ya está en uso en Firebase Authentication.';
    } else if (e.code == 'weak-password') {
      errorMessage = 'La contraseña es demasiado débil.';
    } else {
      errorMessage = 'Error: ${e.message}';
    }

    // Mostrar error en la interfaz con SnackBar
    showAnimatedSnackBar(context, '$e', Colors.red);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error general: $e')),
    );
  }
  return null;
}
