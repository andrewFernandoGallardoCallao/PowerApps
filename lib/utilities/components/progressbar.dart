import 'package:flutter/material.dart';

class ProgressDialog {
  static show(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text(message),
        ],
      ),
    );

    showDialog(
      context: context,
      barrierDismissible:
          false, // Evita que el usuario cierre el diálogo tocando fuera de él
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static hide(BuildContext context) {
    Navigator.of(context).pop(); // Cierra el diálogo de progreso
  }
}