import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateRequest extends StatelessWidget {
  
  CreateRequest({super.key});
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  void addData() {
    firestore.collection('users').add({
      'name': 'John Doe',
      'age': 25,
    }).then((value) {
      print("Usuario agregado");
    }).catchError((error) {
      print("Error al agregar usuario: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Usuario'),
        centerTitle: true,
      ),
      body: ElevatedButton(
        onPressed: () => addData(),
        child: const Text(
          'Crear Usuario'
        ),
      ),
    );
  }
}
