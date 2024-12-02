import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/get_permisos.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

class PermisosScreenHistory extends StatefulWidget {
  const PermisosScreenHistory({
    super.key,
  });

  @override
  State<PermisosScreenHistory> createState() => _PermisosScreenHistoryState();
}

class _PermisosScreenHistoryState extends State<PermisosScreenHistory> {
  bool isLoading = false;
  String searchQuery = ""; // Para almacenar el texto de búsqueda
  String selectedFilter = ""; // Filtro seleccionado
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      color: Color.fromRGBO(66, 66, 66, 1),
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6D8586),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8F0B45),
                          width: 1,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: mainColor,
                        size: 20,
                      ),
                      hintText: 'Buscar por nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    cursorColor: Colors.grey[800],
                    textInputAction: TextInputAction.next,
                  ),
                ),
                IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: mainColor,
                    size: 30,
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nombre',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 2),
            SizedBox(height: 10),
            GetPermisosScreen(accion: 1, searchQuery: searchQuery),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 16),
              // Ordenar por fecha
              ListTile(
                title: const Text('Fecha (Recientes primero)'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  setState(() {
                    selectedFilter = 'FechaRecientes';
                  });
                  Navigator.pop(context); // Cerrar el BottomSheet
                },
              ),
              ListTile(
                title: const Text('Fecha (Antiguas primero)'),
                leading: const Icon(Icons.calendar_today_outlined),
                onTap: () {
                  setState(() {
                    selectedFilter = 'FechaAntiguas';
                  });
                  Navigator.pop(context); // Cerrar el BottomSheet
                },
              ),
              Divider(
                thickness: 0.7,
                color: Colors.grey[500],
              ),
              // Ordenar por nombre
              ListTile(
                title: const Text('Nombre (A-Z)'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  setState(() {
                    selectedFilter = 'NombreAZ';
                  });
                  Navigator.pop(context); // Cerrar el BottomSheet
                },
              ),
              ListTile(
                title: const Text('Nombre (Z-A)'),
                leading: const Icon(Icons.sort_by_alpha_outlined),
                onTap: () {
                  setState(() {
                    selectedFilter = 'NombreZA';
                  });
                  Navigator.pop(context); // Cerrar el BottomSheet
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
