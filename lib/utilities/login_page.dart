// ignore_for_file: use_build_context_synchronously

import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/text_form_field_model.dart';
import 'package:power_apps_flutter/utilities/create_user.dart';
import 'package:power_apps_flutter/utilities/menu_student.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: mainColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'lib/assets/img/logoUnivalle.png',
                  height: sizeScreen.height / 3,
                ),
                Form(
                  key: _formKey,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 40,
                    shadowColor: Colors.grey[900],
                    margin: const EdgeInsets.all(30),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormFieldModel(
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
                          ),
                          const SizedBox(height: 20),
                          TextFormFieldModel(
                            isPasswordField: true,
                            controller: _passwordController,
                            textAttribute: 'su Contraseña',
                            icon: const Icon(
                              Icons.lock,
                              color: mainColor,
                            ),
                            inputFormatter: const [],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Porfavor ingrese su contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sizeScreen.width * 0.2,
                                    vertical: 20, // Altura del botón
                                  ),
                                  backgroundColor: mainColor,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    String email = _emailController.text.trim();
                                    String password =
                                        _passwordController.text.trim();

                                    if (email.isNotEmpty &&
                                        password.isNotEmpty) {
                                      try {
                                        // Autenticación con Firebase Authentication
                                        UserCredential? credenciales =
                                            await login(email, password);

                                        if (credenciales != null &&
                                            credenciales.user != null) {
                                          if (credenciales
                                              .user!.emailVerified) {
                                            // Obtener información del usuario desde Firestore
                                            DocumentSnapshot userDoc =
                                                await FirebaseFirestore.instance
                                                    .collection('student')
                                                    .doc(credenciales.user!.uid)
                                                    .get();

                                            _emailController.clear();
                                            _passwordController.clear();

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StudentMainMenu(
                                                  student: Student(
                                                    id: userDoc.id,
                                                    name: userDoc['name'],
                                                    password:
                                                        userDoc['password'],
                                                    mail: userDoc['mail'],
                                                    career: userDoc['career'],
                                                    type: userDoc['type'],
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Si el correo no está verificado
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Por favor verifique su correo electrónico.'),
                                              ),
                                            );
                                          }
                                        } else {
                                          // Manejo de error si el usuario no existe
                                          throw FirebaseAuthException(
                                              code: 'user-not-found',
                                              message:
                                                  'Usuario o contraseña incorrectos.');
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        // Manejo de errores de Firebase Authentication
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(e.message ??
                                                  'Error de autenticación.')),
                                        );
                                      } on FirebaseException catch (e) {
                                        // Manejo de errores de Firebase Firestore
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(e.message ??
                                                  'Error al acceder a Firestore.')),
                                        );
                                      } catch (e) {
                                        // Manejo de cualquier otro error
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Error inesperado, intente nuevamente.')),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),
                              // Botón de Sign Up
                              ElevatedButton(
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
                                onPressed: () {
                                  _emailController.clear();
                                  _passwordController.clear();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateUserPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  ' Registrarse  ',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Función con Firebase Authentication
Future<UserCredential?> login(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('Usuario no encontrado.');
    } else if (e.code == 'wrong-password') {
      print('Contraseña incorrecta.');
    } else {
      print('Error: ${e.message}');
    }
  } catch (e) {
    print('Error general: $e');
  }
  return null;
}

// Función con student en Firestore
Future<DocumentSnapshot?> loginWithFirestore(
    String email, String password) async {
  try {
    QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('student')
        .where('mail', isEqualTo: email)
        .where('password',
            isEqualTo: password) // Verificación directa (cambiar?)
        .get();

    if (studentSnapshot.docs.isNotEmpty) {
      // Devuelve el primer documento que coincide
      return studentSnapshot.docs.first;
    } else {
      return null; // Usuario no encontrado
    }
  } catch (e) {
    print('Error al autenticar con Firestore: $e');
    return null;
  }
}
