// lib/pages/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

import 'package:noted_pak/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  String _recognizedText = '';
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  bool _cameraInitializationFailed = false;

  @override
  void initState() {
    super.initState();
    print('CameraScreen: initState called.');
    // Jadwalkan inisialisasi kamera setelah frame pertama dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    print('CameraScreen: _initializeCamera called.');

    if (cameras.isEmpty) {
      print('CameraScreen: No cameras found globally. Exiting camera initialization.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( // Ini yang menyebabkan error sebelumnya
          const SnackBar(content: Text('No cameras available or failed to initialize earlier.')),
        );
        setState(() {
          _cameraInitializationFailed = true;
        });
      }
      return;
    }

    if (controller != null && controller!.value.isInitialized) {
      print('CameraScreen: Controller already initialized.');
      if (mounted) { // Pindahkan ini ke dalam mounted check
        setState(() {
          _isCameraInitialized = true;
        });
      }
      return;
    }

    print('CameraScreen: Attempting to create CameraController.');
    controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      print('CameraScreen: Calling controller.initialize().');
      await controller!.initialize();
      print('CameraScreen: controller.initialize() completed.');

      if (!mounted) {
        print('CameraScreen: Widget not mounted after initialization.');
        return;
      }
      setState(() {
        _isCameraInitialized = true;
        _cameraInitializationFailed = false;
      });
      print('CameraScreen: _isCameraInitialized set to true. UI should update.');
    } on CameraException catch (e) {
      _logError(e.code, e.description);
      print('CameraScreen: CameraException during initialization: ${e.code}, ${e.description}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: ${e.description}')),
        );
        setState(() {
          _cameraInitializationFailed = true;
        });
      }
    } catch (e) {
      print('CameraScreen: Generic error during camera initialization: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown error initializing camera: $e')),
        );
         setState(() {
          _cameraInitializationFailed = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      print('CameraScreen: App inactive, disposing camera.');
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      print('CameraScreen: App resumed, re-initializing camera.');
      // Pastikan kamera belum diinisialisasi ulang jika sudah aktif
      if (controller != null && !controller!.value.isInitialized) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    print('CameraScreen: dispose called.');
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _logError(String code, String? message) {
    print('Error: $code\nMessage: $message');
  }

  Future<void> _takePictureAndRecognizeText() async {
    if (!_isCameraInitialized || controller == null || !controller!.value.isInitialized) {
      _logError('Controller not initialized', 'Camera not ready.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not ready. Please try again.')),
        );
      }
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    print('CameraScreen: Taking picture...');
    try {
      final XFile file = await controller!.takePicture();
      print('CameraScreen: Picture taken: ${file.path}. Processing text...');
      final inputImage = InputImage.fromFilePath(file.path);
      final text = await _textRecognizer.processImage(inputImage);
      _recognizedText = text.text;
      print('CameraScreen: Text recognized. Length: ${_recognizedText.length}');

      if (mounted) {
        Navigator.pop(context, _recognizedText);
      }
    } on CameraException catch (e) {
      _logError(e.code, e.description);
      print('CameraScreen: CameraException during picture taking: ${e.code}, ${e.description}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: ${e.description}')),
        );
      }
    } catch (e) {
      print('CameraScreen: Error recognizing text: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to recognize text: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
      print('CameraScreen: Processing finished.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraInitializationFailed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Text')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to initialize camera.', style: TextStyle(fontSize: 18)),
              const Text('Please check permissions or try restarting the app.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Text'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: _takePictureAndRecognizeText,
                      child: const Icon(Icons.camera_alt),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}