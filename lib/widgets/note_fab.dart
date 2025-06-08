// lib/widgets/note_fab.dart
import 'package:flutter/material.dart';
import '../core/constants.dart'; // Import constants untuk warna

class NoteFab extends StatelessWidget {
  final VoidCallback onPressed;

  const NoteFab({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF5B9BD5), // Menggunakan warna dari constants jika ada
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed, // Menggunakan callback onPressed dari parameter
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}