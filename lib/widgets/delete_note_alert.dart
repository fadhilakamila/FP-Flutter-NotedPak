import 'package:flutter/material.dart';

class DeleteNoteAlert extends StatelessWidget {
  const DeleteNoteAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog( // Menggunakan AlertDialog bawaan Flutter yang lebih mudah diatur
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0), // Rounded corners sesuai desain iOS
      ),
      // Konten dialog
      content: Column(
        mainAxisSize: MainAxisSize.min, // Agar column mengambil ruang seminimal mungkin
        children: <Widget>[
          const Text(
            'Are you sure you want to delete?',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w600, // Semi-bold
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0), // Jarak antara teks dan tombol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Menyebar tombol secara horizontal
            children: <Widget>[
              // Tombol Yes
              Expanded(
                child: SizedBox( // Menggunakan SizedBox untuk mengatur tinggi tombol
                  height: 44.0, // Tinggi tombol standar iOS
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Mengembalikan true untuk konfirmasi delete
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF), // Biru khas iOS
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Radius tombol
                      ),
                      elevation: 0, // Tanpa shadow
                      padding: EdgeInsets.zero, // Hapus padding default
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12), // Jarak antara tombol
              // Tombol Cancel
              Expanded(
                child: SizedBox(
                  height: 44.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Mengembalikan false jika dibatalkan
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E5EA), // Warna abu-abu terang
                      foregroundColor: const Color(0xFF0A84FF), // Teks biru khas iOS
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // Properti lain dari AlertDialog, seperti title, actions, dll, dapat diatur di sini
      // Untuk tampilan seperti gambar, kita hanya perlu content.
    );
  }
}