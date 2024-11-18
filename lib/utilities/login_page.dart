import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/assets/escudo_universidad.png',
                height: 150,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo Universitario',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su correo';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              String email = _emailController.text;
                              String password = _passwordController.text;

                              if (email.isNotEmpty && password.isNotEmpty) {
                                // Verificar con Firebase Authentication
                                UserCredential? credenciales =
                                    await login(email, password);
                                DocumentSnapshot userDoc =
                                    await FirebaseFirestore.instance
                                        .collection('student')
                                        .doc(credenciales!.user!.uid)
                                        .get();

                                if (credenciales != null &&
                                    credenciales.user != null) {
                                  if (credenciales.user!.emailVerified) {
                                    // Limpiar los campos de email y contraseña antes de navegar
                                    _emailController.clear();
                                    _passwordController.clear();

                                    // ignore: use_build_context_synchronously
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentMainMenu(
                                          student: Student(
                                            id: userDoc.id,
                                            name: userDoc['name'],
                                            password: userDoc['password'],
                                            mail: userDoc['mail'],
                                            career: userDoc['career'],
                                            type: userDoc['type'],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Por favor verifique su correo electrónico.')),
                                    );
                                  }
                                } else {
                                  // Autenticar con Firestore
                                  DocumentSnapshot? userDoc =
                                      await loginWithFirestore(email, password);
                                  if (userDoc != null) {
                                    // Verifica el campo "type" en el documento
                                    String userType = userDoc.get("type");

                                    // Limpiar los campos de email y contraseña antes de navegar
                                    _emailController.clear();
                                    _passwordController.clear();

                                    // if (userType == "Student") {
                                    //   Navigator.pushNamed(
                                    //       context, 'MenuStudent');
                                    // } else {
                                    //   Navigator.pushNamed(
                                    //       context, 'PermisionScreen');
                                    // }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Correo o contraseña incorrectos.')),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: Text('Iniciar Sesión',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Botón de Sign Up
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                          ),
                          onPressed: () {
                            // Limpiar los campos de email y contraseña antes de navegar
                            _emailController.clear();
                            _passwordController.clear();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateUserPage(),
                              ),
                            );
                          },
                          child: Text('Sign Up',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
