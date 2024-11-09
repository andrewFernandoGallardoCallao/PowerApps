import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

class ComboBox extends StatefulWidget {
  final List<String> itemsList;
  final String hintText;
  final Icon icon;
  final String? selectedValue;
  final ValueChanged<String?> onChanged; // Callback para notificar cambios

  ComboBox({
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
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
        hintText: 'Seleccione la ${widget.hintText}',
        hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: widget.icon,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      style: const TextStyle(fontSize: 18, color: Colors.black87),
      value: widget.selectedValue,
      items: widget.itemsList.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        widget.onChanged(newValue); // Notificar al padre del cambio
      },
    );
  }
}
