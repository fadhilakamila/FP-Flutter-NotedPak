import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noted_pak/firebase_options.dart';import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';

import 'package:noted_pak/pages/main_page.dart';
import 'package:noted_pak/pages/registration_page.dart';
import 'package:noted_pak/pages/login_page.dart';
import 'package:noted_pak/pages/recover_password_page.dart';
import 'package:noted_pak/pages/edit_page.dart';

import 'package:noted_pak/models/note.dart';
import 'package:noted_pak/change_notifiers/notes_provider.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      print('Warning: No cameras found on this device.');
    }
  } on CameraException catch (e) {
    print('Error initializing cameras: ${e.description}');
  }

  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: MaterialApp(
        title: 'NotedPak App',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
        debugShowCheckedModeBanner: false,

        initialRoute: '/login',

        routes: {
          '/register': (context) => const RegistrationPage(),
          '/login': (context) => const LoginPage(),
          '/recover': (context) => const RecoverPasswordPage(),

          '/home': (context) => ChangeNotifierProvider(
                create: (context) => NotesProvider(),
                child: const NotedPakHomePage(),
              ),

          '/edit_note': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return NewOrEditNotePage(
              existingNote: args?['existingNote'],
              isReadOnly: args?['isReadOnly'] ?? false,
              initialContent: args?['initialContent'] as String?, // Pastikan ini ditambahkan
            );
          },

          '/new_note': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?; // Tangani argumen
            return NewOrEditNotePage(
              initialContent: args?['initialContent'] as String?, // Teruskan initialContent
            );
          },
        },
      ),
    );
  }
}