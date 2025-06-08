import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:noted_pak/pages/main_page.dart';
import 'package:noted_pak/pages/registration_page.dart';
import 'package:noted_pak/pages/login_page.dart';
import 'package:noted_pak/pages/recover_password_page.dart';
import 'package:noted_pak/pages/edit_page.dart'; // Impor NewOrEditNotePage dari pages/edit_page.dart

import 'package:noted_pak/models/note.dart';
import 'package:noted_pak/change_notifiers/notes_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dummyExistingNote = {
      'title': 'Ubur-ubur Ikan Lele',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ..',
      'tags': ['Life', 'College'],
      'createdDate': DateTime(2025, 1, 29, 3, 30).toIso8601String(),
      'lastModifiedDate': DateTime(2025, 8, 10, 10, 30).toIso8601String(),
    };

    return MaterialApp(
      title: 'NotedPak App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      
      initialRoute: '/edit_note_direct',

      routes: {
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/recover': (context) => RecoverPasswordPage(),
        
        '/home': (context) => ChangeNotifierProvider(
          create: (context) => NotesProvider(),
          child: const NotedPakHomePage(),
        ),
        
        '/edit_note': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return NewOrEditNotePage(
            existingNote: args?['existingNote'],
            isReadOnly: args?['isReadOnly'] ?? false,
          );
        },
        
        '/new_note': (context) {
          return NewOrEditNotePage();
        },

        '/edit_note_direct': (context) {
          return NewOrEditNotePage(existingNote: dummyExistingNote);
        },
      },
    );
  }
}
