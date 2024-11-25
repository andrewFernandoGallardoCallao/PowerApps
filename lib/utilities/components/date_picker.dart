import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

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
      firstDate: DateTime.now().subtract(
          const Duration(days: 30)), // Opcional: Controlar fechas mínimas
      lastDate: DateTime.now()
          .add(const Duration(days: 7)), // Opcional: Controlar fechas máximas
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mainColor,
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
        // Si la fecha está fuera del rango de 72 horas, mostramos un SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La licencia no puede pedirse con más de 72 horas de anticipación.',
            ),
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
        hintText: 'Seleccione Fecha',
        hintStyle: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
        prefixIcon: const Icon(
          Icons.calendar_month,
          color: mainColor,
        ),
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
      ),
    );
  }
}
