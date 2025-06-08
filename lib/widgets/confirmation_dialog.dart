// lib/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;
  final Color confirmButtonColor;
  final Color cancelButtonColor;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmButtonText = 'Yes', // Default text
    this.cancelButtonText = 'Cancel', // Default text
    this.confirmButtonColor = Colors.red, // Default color for destructive actions
    this.cancelButtonColor = Colors.grey, // Default color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Mengembalikan false jika dibatalkan
          },
          child: Text(
            cancelButtonText,
            style: TextStyle(color: cancelButtonColor),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Mengembalikan true jika dikonfirmasi
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}