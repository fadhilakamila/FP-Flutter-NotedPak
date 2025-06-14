import 'package:flutter/material.dart';
import 'package:noted_pak/change_notifiers/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noted_pak/firebase_options.dart';

import 'package:noted_pak/pages/main_page.dart';
import 'package:noted_pak/pages/registration_page.dart';
import 'package:noted_pak/pages/login_page.dart';
import 'package:noted_pak/pages/recover_password_page.dart';
import 'package:noted_pak/pages/edit_page.dart';

import 'package:noted_pak/models/note.dart';

void main() async {
  await initializeFirebase();
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
    final Map<String, dynamic> dummyExistingNote = {
      'id': 'ID_CATATAN_YANG_ADA_DI_FIRESTORE_ANDA', // <<<--- GANTI DENGAN ID ASLI DARI FIRESTORE
      'title': 'Pengeluaran Hari Ini (Updated)',
      'content': 'Bakso 20.000\nBioskop 35.000\nEs Teh 5.000',
      'tags': ['Finance', 'Hemat', 'Daily'],
      'dateCreated': DateTime(2025, 1, 29, 3, 30), // Kirim sebagai DateTime
      'dateModified': DateTime(2025, 8, 10, 10, 30), // Kirim sebagai DateTime
      // 'type': NoteType.daily.toString().split('.').last,
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        // Tambahkan provider lain di sini jika ada (misal: AuthProvider)
      ],
      child: MaterialApp(
        title: 'NotedPak App',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
        debugShowCheckedModeBanner: false,

        initialRoute: '/register',
        // Anda bisa ubah ke '/login' setelah testing CRUD Firebase selesai.

        routes: {
          '/register': (context) => const RegistrationPage(),
          '/login': (context) => const LoginPage(),
          '/recover': (context) => const RecoverPasswordPage(),

          '/home': (context) => ChangeNotifierProvider(
                create: (context) => NotesProvider(),
                child: const NotedPakHomePage(),
              ),

          '/edit_note': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return NewOrEditNotePage(
              existingNote: args?['existingNote'],
              isReadOnly: args?['isReadOnly'] ?? false,
            );
          },

          '/new_note': (context) {
            return const NewOrEditNotePage();
          },

          '/edit_note_direct': (context) {
            return NewOrEditNotePage(existingNote: dummyExistingNote);
          },
        },
      ),
    );
  }
}