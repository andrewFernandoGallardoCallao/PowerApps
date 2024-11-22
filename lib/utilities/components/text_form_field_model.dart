import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_apps_flutter/utilities/reusables/input_decoration.dart';

class TextFormFieldModel extends StatefulWidget {
  final TextEditingController controller;
  final String textAttribute;
  final Icon icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatter;
  final String? Function(String?)? validator;
  final bool isPasswordField;
  
  // Constructor corregido con parámetros nombrados requeridos
  const TextFormFieldModel({
    super.key,
    this.isPasswordField = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
    required this.textAttribute,
    required this.icon,
    required this.inputFormatter,
    required this.validator,
  });

  @override
  State<TextFormFieldModel> createState() => _TextFormFieldModelState();
}

class _TextFormFieldModelState extends State<TextFormFieldModel> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPasswordField ? _isObscured : false,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatter,
      decoration: inputDecorationForm(
        widget.textAttribute,
        widget.icon,
        isPassword: widget.isPasswordField ? _isObscured : null,
        toggleVisibility: widget.isPasswordField
            ? () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              }
            : null,
      ),
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 18,
        color: Color.fromRGBO(66, 66, 66, 1),
      ),
      cursorColor: Colors.grey[800],
      textInputAction: TextInputAction.next,
      validator: widget.validator,
    );
  }
}
