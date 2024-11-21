import 'package:flutter/material.dart';

class ComboBox extends StatefulWidget {
  final List<String> itemsList;
  final String hintText;
  final Icon icon;
  final String? selectedValue;
  final ValueChanged<String?> onChanged; // Callback para notificar cambios

  const ComboBox({
    super.key,
    required this.itemsList,
    required this.hintText,
    required this.icon,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<ComboBox> createState() => _ComboBoxState();
}

class _ComboBoxState extends State<ComboBox> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccione ${widget.hintText}',
        labelStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
        hintText: 'Seleccione ${widget.hintText}',
        hintStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
        ),
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
            color: Color(0xFF950A67),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF950A67),
            width: 1,
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
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
      onChanged: (String? newValue) {
        widget.onChanged(newValue); // Notificar al padre del cambio
      },
    );
  }
}
