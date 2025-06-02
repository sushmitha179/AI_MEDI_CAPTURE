import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts _flutterTts = FlutterTts();

Future<void> _speakText(String text) async {
  await _flutterTts.setLanguage("en-US");
  await _flutterTts.setPitch(1);
  await _flutterTts.setSpeechRate(0.5);
  await _flutterTts.speak(text);
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _captureAndRecognize() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFile(File(image.path));
      final textRecognizer = TextRecognizer();
      final result = await textRecognizer.processImage(inputImage);
      final recognizedText = result.text.trim();

      setState(() => _recognizedText = recognizedText);
      await _saveToFirestore(recognizedText);
      await _speakText(recognizedText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToFirestore(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
      'title': 'New Scan Saved',
      'message': 'Your scan was recognized and saved successfully.',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = const Color(0xFF4E2A6E);
    final Color buttonBg = isDark ? Colors.white : Colors.white;
    final Color buttonFg = accentColor;
    final Color overlayBg =
        isDark ? Colors.grey[900]! : const Color(0xFFF1EFFF);
    final Color textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController),
                ),

                // 🎯 Capture Button
                Positioned(
                  bottom: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _captureAndRecognize,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("Capture & Recognize"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBg,
                        foregroundColor: buttonFg,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                ),

                // 🔁 Clear Button
                if (_recognizedText.isNotEmpty)
                  Positioned(
                    bottom: 180,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'clearText',
                      onPressed: () {
                        setState(() => _recognizedText = '');
                        _flutterTts.stop();
                      },
                      backgroundColor: Colors.red.shade400,
                      child: const Icon(Icons.refresh),
                      tooltip: 'Clear recognized text',
                    ),
                  ),

                // 📜 Recognized Text Overlay
                if (_recognizedText.isNotEmpty)
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.2,
                    maxChildSize: 0.65,
                    builder: (context, controller) => Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, -3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        controller: controller,
                        children: [
                          Text(
                            '🤖 AI Recognized Text',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: overlayBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              _recognizedText,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
