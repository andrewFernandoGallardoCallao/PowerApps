import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estudiante')),
      body: Center(child: Text('Página de Estudiante')),
    );
  }
}

/*class LoginP extends StatefulWidget {
  @override
  State createState() {
    return _LoginS();
  }
}

class _LoginS extends State<LoginP> {
  @override
  late String email, password;
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          btnLogin()
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
        child: Column(
      children: [
        buildEmail(),
        const Padding(padding: EdgeInsets.only(top: 12)),
        buildPassword(),
      ],
    ));
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Correo Universitario",
          border: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(7),
              borderSide: new BorderSide(color: Colors.black))),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Contraseña",
          border: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(7),
              borderSide: new BorderSide(color: Colors.black))),
      obscureText: true,
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget btnLogin() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              UserCredential? credenciales = await login(email, password);
              if (credenciales != null) {
                if (credenciales.user != null) {
                  if (credenciales.user!.emailVerified) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => DirectorPage()),
                        (Route<dynamic> route) => false);
                  }
                  else{
                    // Mensaje pal usuario
                  }
                }
              }
            }
          },
          child: Text("Login")),
    );
  }
}

Future<UserCredential?> login(String email, String pssword) async {
  try{
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, password: pssword);
      return userCredential;
  }
  on FirebaseAuthException catch(e){
    if(e.code == 'user-not-found')
    {
      // user no encontrado
    }
      if(e.code == 'wrong-password')
    {
      // contraseña incorrecta
    }
  }
}*/
