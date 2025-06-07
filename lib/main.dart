import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotedPak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignUpScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
