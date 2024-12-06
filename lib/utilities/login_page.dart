// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/models/director.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/components/menu_director.dart';
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
  bool _isLoading = false; // Estado de carga
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
      backgroundColor: null,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizeScreen.width <= 600 ? 20.0 : 100.0,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                Image.asset(
                  'lib/assets/img/escudoUni.png',
                  height: sizeScreen.height / 4,
                ),
                const SizedBox(height: 20),
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
                            textAttribute: 'su contraseña',
                            icon: const Icon(
                              Icons.lock,
                              color: mainColor,
                            ),
                            inputFormatter: const [],
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su contraseña';
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
                                    horizontal:
                                        MediaQuery.of(context).size.width * 0.2,
                                    vertical: 20, // Altura del botón
                                  ),
                                  backgroundColor: mainColor, // Cambia el color
                                ),
                                onPressed: _isLoading
                                    ? null // Desactivar el botón mientras se carga
                                    : () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          setState(() {
                                            _isLoading =
                                                true; // Comienza la carga
                                          });

                                          String email =
                                              _emailController.text.trim();
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
                                                  // Verificar si el usuario es un estudiante o un director
                                                  DocumentSnapshot
                                                      userDocStudent =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('student')
                                                          .doc(credenciales
                                                              .user!.uid)
                                                          .get();

                                                  DocumentSnapshot
                                                      userDocDirector =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'director')
                                                          .doc(credenciales
                                                              .user!.uid)
                                                          .get();

                                                  // Si se encuentra en la colección 'student'
                                                  if (userDocStudent.exists) {
                                                    _emailController.clear();
                                                    _passwordController.clear();

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StudentMainMenu(
                                                          student: Student(
                                                            id: userDocStudent
                                                                .id,
                                                            name:
                                                                userDocStudent[
                                                                    'name'],
                                                            mail:
                                                                userDocStudent[
                                                                    'mail'],
                                                            career:
                                                                userDocStudent[
                                                                    'career'],
                                                            type:
                                                                userDocStudent[
                                                                    'type'],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  // Si se encuentra en la colección 'director'
                                                  else if (userDocDirector
                                                      .exists) {
                                                    _emailController.clear();
                                                    _passwordController.clear();

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DirectorMainMenu(
                                                          director: Director(
                                                            id: userDocDirector
                                                                .id,
                                                            name:
                                                                userDocDirector[
                                                                    'name'],
                                                            password:
                                                                userDocDirector[
                                                                    'password'],
                                                            career:
                                                                userDocDirector[
                                                                    'career'],
                                                            mail:
                                                                userDocDirector[
                                                                    'mail'],
                                                            type:
                                                                userDocDirector[
                                                                    'type'],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Si no se encuentra en ninguna de las colecciones
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Usuario no encontrado en las colecciones.'),
                                                      ),
                                                    );
                                                  }
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
                                            } finally {
                                              setState(() {
                                                _isLoading =
                                                    false; // Termina la carga
                                              });
                                            }
                                          }
                                        }
                                      },
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors
                                            .white) // Muestra el progress bar
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
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
                                    horizontal:
                                        MediaQuery.of(context).size.width * 0.2,
                                    vertical: 20,
                                  ),
                                ),
                                onPressed:
                                    _isLoading // Desactivar el botón de registro mientras se está logueando
                                        ? null
                                        : () {
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
