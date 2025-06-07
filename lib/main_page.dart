import 'package:flutter/material.dart';

void main() {
  runApp(const NotedPakApp());
}

class NotedPakApp extends StatelessWidget {
  const NotedPakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotedPak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const NotedPakHomePage(),
    );
  }
}

// Custom painter untuk membuat icon NotedPak yang PERSIS sesuai referensi terbaru
class NotedPakIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Warna biru gradient sesuai referensi
    final blueColor = const Color(0xFF5B9BD5);
    final strokeWidth = size.width * 0.08; // Ketebalan stroke yang proporsional

    // Dokumen belakang (kiri atas) - hanya outline/stroke
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = blueColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width * 0.7,
        size.height * 0.75,
      ),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(rect1, paint);

    // Dokumen depan (kanan bawah) - juga hanya outline/stroke
    final rect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.75,
      ),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(rect2, paint);

    // Corner fold - lipatan sudut kanan bawah pada dokumen depan
    final foldSize = size.width * 0.15;
    final docRight = size.width * 0.95;
    final docBottom = size.height * 0.95;

    // Fill untuk area lipatan
    paint
      ..style = PaintingStyle.fill
      ..color = blueColor;

    final foldPath = Path();
    foldPath.moveTo(docRight - foldSize, docBottom);
    foldPath.lineTo(docRight, docBottom - foldSize);
    foldPath.quadraticBezierTo(
      docRight - foldSize * 0.4,
      docBottom - foldSize * 0.4,
      docRight,
      docBottom,
    );
    foldPath.close();

    canvas.drawPath(foldPath, paint);

    // Garis tepi untuk lipatan
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6
      ..color = blueColor;

    final foldLine = Path();
    foldLine.moveTo(docRight - foldSize, docBottom);
    foldLine.lineTo(docRight, docBottom - foldSize);
    canvas.drawPath(foldLine, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NotedPakHomePage extends StatelessWidget {
  const NotedPakHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'NotedPak!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5B9BD5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.grey[600], size: 24),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon/Logo NotedPak - Dibuat dengan presisi tinggi
                  // ignore: sized_box_for_whitespace
                  Container(
                    width: 120,
                    height: 120,
                    child: CustomPaint(painter: NotedPakIconPainter()),
                  ),

                  const SizedBox(height: 32),

                  // Text - Font yang lebih tebal
                  Column(
                    children: [
                      Text(
                        'You have no notes yet,',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF5B9BD5),
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Start creating by pressing the + button below!',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF5B9BD5),
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF5B9BD5),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
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
            onTap: () {
              _showAddNoteDialog(context);
            },
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: const Text(
            'Feature to add new note will be implemented here.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
