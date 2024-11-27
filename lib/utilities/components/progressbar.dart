import 'package:flutter/material.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';

class ProgressBar {
  static void showProgressDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: mainColor),
                const SizedBox(width: 20),
                Text("$message..."),
              ],
            ),
          ),
        );
      },
    );
  }

  static void closeProgressDialog(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo.
  }
}
