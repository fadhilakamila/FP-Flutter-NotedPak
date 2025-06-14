import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Sudah ada
import 'package:noted_pak/firebase_options.dart'; // Sudah ada

import 'package:noted_pak/pages/main_page.dart';
import 'package:noted_pak/pages/registration_page.dart';
import 'package:noted_pak/pages/login_page.dart';
import 'package:noted_pak/pages/recover_password_page.dart';
import 'package:noted_pak/pages/edit_page.dart'; // Impor NewOrEditNotePage

import 'package:noted_pak/models/note.dart'; // <<<--- Tambahkan import ini untuk NoteType
import 'package:noted_pak/change_notifiers/notes_provider.dart';

// <<<--- PERUBAHAN: Fungsi main() sekarang async dan memanggil initializeFirebase()
void main() async {
  await initializeFirebase(); // Panggil fungsi inisialisasi Firebase
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
    // Dummy note untuk testing update/delete.
    // PENTING: Untuk menguji update/delete pada catatan yang sudah ada di Firebase,
    // Anda harus mengganti 'ID_CATATAN_YANG_ADA_DI_FIRESTORE_ANDA'
    // dengan ID dokumen nyata dari Firestore Anda.
    final Map<String, dynamic> dummyExistingNote = {
      'id': 'ID_CATATAN_YANG_ADA_DI_FIRESTORE_ANDA', // <<<--- GANTI DENGAN ID ASLI DARI FIRESTORE
      'title': 'Pengeluaran Hari Ini (Updated)',
      'content': 'Bakso 20.000\nBioskop 35.000\nEs Teh 5.000',
      'tags': ['Finance', 'Hemat', 'Daily'],
      // <<<--- PERUBAHAN: Gunakan properti tanggal yang konsisten dengan Note model
      'dateCreated': DateTime(2025, 1, 29, 3, 30), // Kirim sebagai DateTime
      'dateModified': DateTime(2025, 8, 10, 10, 30), // Kirim sebagai DateTime
      'type': NoteType.daily.toString().split('.').last, // <<<--- Tambahkan ini untuk konsistensi tipe
    };

    return MultiProvider( // <<<--- PERUBAHAN: Menggunakan MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        // Tambahkan provider lain di sini jika ada (misal: AuthProvider)
      ],
      child: MaterialApp(
        title: 'NotedPak App',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
        debugShowCheckedModeBanner: false,

        initialRoute: '/register', // <<<--- DIUBAH: Untuk memudahkan pengujian catatan baru
        // Anda bisa ubah ke '/login' setelah testing CRUD Firebase selesai.

        routes: {
          '/register': (context) => const RegistrationPage(),
          '/login': (context) => const LoginPage(),
          '/recover': (context) => const RecoverPasswordPage(),

          '/home': (context) => ChangeNotifierProvider(
                create: (context) => NotesProvider(), // Provider ini akan di-override oleh MultiProvider di atas.
                                                     // Sebaiknya hapus ini jika `/home` juga dibungkus oleh MultiProvider utama.
                                                     // Jika tidak, biarkan saja jika `/home` adalah entry point terpisah.
                                                     // Untuk kesederhanaan, saya sarankan menghapus ChangeNotifierProvider di sini
                                                     // dan pastikan NotedPakHomePage tidak punya provider sendiri
                                                     // atau menerima provider dari parent.
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
            return const NewOrEditNotePage(); // Catatan baru (existingNote: null)
          },

          '/edit_note_direct': (context) {
            return NewOrEditNotePage(existingNote: dummyExistingNote);
          },
        },
      ),
    );
  }
}