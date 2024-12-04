import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

class ComboBox extends StatefulWidget {
  final List<String> itemsList;
  final String hintText;
  final Icon icon;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onTap;

  const ComboBox({
    super.key,
    required this.itemsList,
    required this.hintText,
    required this.icon,
    required this.selectedValue,
    required this.onChanged,
    this.onTap, // onTap es opcional
  });

  @override
  State<ComboBox> createState() => _ComboBoxState();
}

class _ComboBoxState extends State<ComboBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelStyle: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          hintText: 'Seleccione la ${widget.hintText}',
          hintStyle: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: widget.icon,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: mainColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: mainColor,
              width: 1,
            ),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        value: widget.selectedValue,
        items: widget.itemsList.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(color: Colors.grey[800]),
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}
