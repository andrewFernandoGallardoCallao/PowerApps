import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/get_permisos.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

class PermisosScreen extends StatefulWidget {
  const PermisosScreen({
    super.key,
  });

  @override
  State<PermisosScreen> createState() => _PermisosScreenState();
}

class _PermisosScreenState extends State<PermisosScreen> {
  final permisosRef = instance.collection('request');
  bool isLoading = false;
  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
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
                  onPressed: () {},
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
            GetPermisosScreen(accion: 0, searchQuery: searchQuery),
          ],
        ),
      ),
    );
  }
}
