import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/firebase_instance.dart';
import 'package:power_apps_flutter/utilities/components/get_permisos.dart';

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
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.sizeOf(context);
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
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
            Divider(thickness: 2),
            SizedBox(height: 40),
            GetPermisosScreen(
              permisoEstado: "Pendiente",
              accion: 0,
            ),
          ],
        ),
      ),
    );
  }
}
