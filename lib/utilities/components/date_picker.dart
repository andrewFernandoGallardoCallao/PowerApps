import 'package:flutter/material.dart';

class SimpleDatePickerFormField extends StatefulWidget {
  final ValueChanged<DateTime?> onDateSelected; // Callback para pasar la fecha

  const SimpleDatePickerFormField({
    Key? key,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _SimpleDatePickerFormFieldState createState() =>
      _SimpleDatePickerFormFieldState();
}

class _SimpleDatePickerFormFieldState extends State<SimpleDatePickerFormField> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF950A67), // Color principal
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final difference = pickedDate.difference(DateTime.now()).inHours;

      if (difference > 72) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'La licencia no puede pedirse con más de 72 horas de anticipación.'),
          ),
        );
      } else {
        setState(() {
          _selectedDate = pickedDate;
          _dateController.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        });
        widget.onDateSelected(pickedDate); // Pasamos la fecha al callback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Seleccione Fecha',
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[800], // Color del label
        ),
        hintText: 'Fecha de la licencia',
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        prefixIcon: const Icon(
          Icons.calendar_month,
          color: Color(0xFF950A67), // Color del icono
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200], 
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
    );
  }
}
