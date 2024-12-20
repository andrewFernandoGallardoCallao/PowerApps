import 'package:flutter/material.dart';

InputDecoration inputDecorationForm(String textAttribute, Icon icon) {
  return InputDecoration(
    labelStyle: TextStyle(
      fontSize: 18,
      color: Colors.grey[600],
    ),
    hintText: 'Ingrese $textAttribute',
    hintStyle: TextStyle(
      fontSize: 18,
      color: Colors.grey[400],
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    prefixIcon: icon,
    filled: true,
    fillColor: Colors.grey[300],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.black,
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
  );
}
