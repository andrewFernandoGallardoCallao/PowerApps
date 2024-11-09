import 'package:flutter/material.dart';


class Toast {
  static void show(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
        action: SnackBarAction(
          label: 'Cerrar',
          onPressed: scaffold.hideCurrentSnackBar,
          textColor: Colors.white,
        ),
      ),
    );
  }
}  