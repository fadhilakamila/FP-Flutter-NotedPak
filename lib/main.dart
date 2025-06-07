// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'screens/registration_page.dart';
import 'screens/login_page.dart';
import 'screens/recover_password_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/recover': (context) => RecoverPasswordPage(),
      },
    );
  }
}
