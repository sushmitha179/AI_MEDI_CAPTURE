import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add this

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  String _recognizedText = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
      print('📷 Camera initialized.');
    } catch (e) {
      print('❌ Camera initialization error: $e');
      _showSnackBar('Camera error: $e');
    }
  }

  Future<void> _captureAndRecognizeText() async {
    if (!_cameraController.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      print('📸 Capturing image...');
      final XFile picture = await _cameraController.takePicture();
      final File imageFile = File(picture.path);
      final InputImage inputImage = InputImage.fromFile(imageFile);

      print('🧠 Processing image with ML Kit...');
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      print('✅ Text recognized: ${recognizedText.text}');

      setState(() {
        _recognizedText = recognizedText.text;
      });

      await _saveToFirestore(_recognizedText);
      _showSnackBar('✅ Capture successful. Text recognized.');
    } catch (e) {
      print('❌ Error during recognition: $e');
      _showSnackBar('❌ Recognition error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToFirestore(String recognizedText) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('User not logged in');
        return;
      }

      String uid = user.uid;
      print("👤 Current User UID: $uid");

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scans')
          .doc(timestamp)
          .set({
        'text': recognizedText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ Successfully saved to Firestore');
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      _showSnackBar('Error saving to Firestore: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Handwritten Notes')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _isCameraInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isProcessing ? null : _captureAndRecognizeText,
            child: const Text('Capture & Recognize Text'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/results');
            },
            child: const Text('View Saved Scans'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveToFirestore("🧪 Test Firestore Save Button Pressed");
              _showSnackBar("🧪 Dummy text saved to Firestore.");
            },
            child: const Text('Test Firestore Save'),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText.isEmpty
                      ? 'Recognized text will appear here.'
                      : _recognizedText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
