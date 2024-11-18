// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/models/student_dto.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/snack_bar.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/escudo_universidad.png',
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Registro de Usuario",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF950A67),
                      ),
                    ),
                    const SizedBox(height: 16),
                    formulario(),
                    const SizedBox(height: 20),
                    btnSignUp(),
                  ],
                ),
              ),
            ),
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
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Nombres",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF950A67)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF6D8586)),
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _apellidosController,
            decoration: InputDecoration(
              labelText: "Apellidos",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF950A67)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF6D8586)),
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ciController,
            decoration: InputDecoration(
              labelText: "Ci",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF950A67)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF6D8586)),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cellPhonelController,
            decoration: InputDecoration(
              labelText: "Celular",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF950A67)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF6D8586)),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: "Telefono",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF950A67)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Color(0xFF6D8586)),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          buildCareerDropdown(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Correo Universitario",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Color(0xFF950A67)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Color(0xFF6D8586)),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un correo';
        }
        if (!value.endsWith('@est.univalle.edu')) {
          return 'El correo debe ser de la universidad (@est.univalle.edu)';
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: "Contraseña",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Color(0xFF950A67)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Color(0xFF6D8586)),
        ),
      ),
      obscureText: true,
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'Por favor ingrese una contraseña';
      //   }
      //   // Verificación de contraseña segura
      //   final passwordRegExp =
      //       RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
      //   if (!passwordRegExp.hasMatch(value)) {
      //     return 'La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un carácter especial';
      //   }
      //   return null;
      // },
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

  Widget btnSignUp() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF950A67),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
      ),
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
