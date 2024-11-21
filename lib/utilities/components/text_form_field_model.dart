import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/reusables/input_decoration.dart';

class TextFormFieldModel extends StatelessWidget {
  final TextEditingController controller;
  final String textAttribute;
  final Icon icon;
  final TextInputType keyboardType = TextInputType.text;
  final List<TextInputFormatter> inputFormatter;
  // Constructor corregido con parámetros nombrados requeridos
  const TextFormFieldModel({
    super.key,
    required this.controller,
    required this.textAttribute,
    required this.icon,
    required this.inputFormatter,
    keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatter,
      decoration: inputDecorationForm(textAttribute, icon),
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
      cursorColor: Colors.black,
      textInputAction: TextInputAction.next,
    );
  }
}
