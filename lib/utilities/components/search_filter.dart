import 'package:flutter/material.dart';

class SearchFilter extends StatelessWidget {
  final Function(String) onFilterChanged;

  const SearchFilter({
    Key? key,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar por nombre',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: onFilterChanged,
      ),
    );
  }
}
