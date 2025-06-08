// lib/widgets/note_icon_button.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/constants.dart'; // Import constants

class NoteIconButton extends StatelessWidget {
  const NoteIconButton({
    super.key,
    required this.icon,
    this.size = 24,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: FaIcon(
        icon,
        size: size,
        color: gray700, // Menggunakan warna dari constants
      ),
    );
  }
}