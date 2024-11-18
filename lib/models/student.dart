import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String career;
  final String mail;
  final String type;
  final String name;
  final String password;

  Student({
    required this.name,
    required this.password,
    required this.id,
    required this.career,
    required this.mail,
    required this.type,
  });
}
