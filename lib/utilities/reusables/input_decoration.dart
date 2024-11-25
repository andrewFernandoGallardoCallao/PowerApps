import 'package:flutter/material.dart';

InputDecoration inputDecorationForm(String textAttribute, Icon icon,
    {bool? isPassword, VoidCallback? toggleVisibility}) {
  return InputDecoration(
    labelStyle: const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    hintText: 'Ingrese $textAttribute',
    hintStyle: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 18,
      color: Colors.grey[600],
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    prefixIcon: icon,
    suffixIcon: isPassword != null
        ? IconButton(
            icon: Icon(
              isPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[800],
              size: 20,
            ),
            onPressed: toggleVisibility,
          )
        : null,
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF8F0B45),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF6D8586),
        width: 1.5,
      ),
    ),
  );
}
