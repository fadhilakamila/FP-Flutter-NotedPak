// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
// Ini mengimpor halaman utama aplikasi setelah login
import 'pages/main_page.dart'; // Ini dari branch 'homepage'

// Ini mengimpor halaman-halaman untuk autentikasi
import 'pages/registration_page.dart'; // Dari branch 'main'
import 'pages/login_page.dart'; // Dari branch 'main'
import 'pages/recover_password_page.dart'; // Dari branch 'main'

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotedPak App', // Menggabungkan title dari kedua branch
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Menambahkan font dari branch 'main'
      ),
      debugShowCheckedModeBanner:
          false, // Mempertahankan ini dari branch 'homepage'
      // Kita akan menggunakan routes untuk navigasi awal
      // Dan halaman utama (NotedPakApp) akan diakses setelah login/register
      initialRoute:
          '/home', // Atau '/login' jika kamu ingin langsung ke halaman login
      routes: {
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/recover': (context) => RecoverPasswordPage(),
        // Tambahkan rute untuk halaman utama setelah autentikasi
        '/home': (context) => const NotedPakApp(),
      },
    );
  }
}