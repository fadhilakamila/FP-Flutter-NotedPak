// lib/widgets/message_dialog.dart
import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onButtonPressed;

  const MessageDialog({
    Key? key,
    required this.title,
    required this.content,
    this.buttonText = 'OK', // Default text
    this.buttonColor = Colors.blue, // Default color
    this.onButtonPressed, // Optional callback for button press
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
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Menutup dialog
            if (onButtonPressed != null) {
              onButtonPressed!(); // Panggil callback jika ada
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
}