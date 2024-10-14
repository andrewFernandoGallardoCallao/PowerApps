import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/home_director.dart';
import 'package:power_apps_flutter/utilities/home_student.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String _role = 'Estudiante'; // Solo por ahora

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

              // Correo universitario
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Universitario',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (String? value) {
                  email = value!;
                },
              ),
              SizedBox(height: 20),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                onSaved: (String? value) {
                  password = value!;
                },
              ),
              SizedBox(height: 20),

              // Dropdown de rol
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _role,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>['Estudiante', 'Director'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _role = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Botón de login
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    UserCredential? credenciales = await login(email, password);
                    if (credenciales != null) {
                      if (credenciales.user != null) {
                        if (credenciales.user!.emailVerified) {
                          // Navegación basada en el rol seleccionado
                          if (_role == 'Estudiante') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StudentPage()), 
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DirectorPage()),
                            );
                          }
                        } else {
                          // Mensaje pal usuario
                        }
                      }
                    }
                  }
                },
                child: Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<UserCredential?> login(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      // user no encontrado
    }
    if (e.code == 'wrong-password') {
      // contraseña incorrecta
    }
  }
}
