import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // For TensorFlow Lite
import 'dart:io'; // For File class
import 'package:image/image.dart'; // For image processing
import '../custom_widgets/scanner_frame_painter.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/flower_recognition.tflite');
      setState(() => _isModelLoaded = true);
    } catch (e) {
      debugPrint('Failed to load model: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<String> _classifyImage(String imagePath) async {
    if (_interpreter == null) return 'Model not loaded';

    // Load and preprocess the image
    final imageBytes = File(imagePath).readAsBytesSync();
    final image = decodeImage(imageBytes);
    if (image == null) return 'Failed to decode image';

    // Resize the image to 180x180
    final resizedImage = copyResize(image, width: 180, height: 180);

    // Convert the image to a normalized input array
    final input = List.filled(180 * 180 * 3, 0.0).reshape([1, 180, 180, 3]);
    for (int y = 0; y < 180; y++) {
      for (int x = 0; x < 180; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0; // Normalize red channel
        input[0][y][x][1] = pixel.g / 255.0; // Normalize green channel
        input[0][y][x][2] = pixel.b / 255.0; // Normalize blue channel
      }
    }

    // Run inference
    final output = List.filled(1 * 5, 0.0).reshape([1, 5]);
    _interpreter!.run(input, output);

    // Get the prediction
    return getPrediction(output.cast<List<double>>());
  }
String getPrediction(List<List<double>> output) {
  final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];

  // Ensure output[0] is not empty
  if (output.isEmpty || output[0].isEmpty) {
    return 'No prediction available.';
  }

  // Find the index of the maximum value in output[0]
  final predictedIndex = output[0].indexOf(output[0].reduce((double a, double b) => a > b ? a : b));

  // Calculate confidence percentage
  final confidence = output[0][predictedIndex] * 100;

  // Return the result
  return 'The image belongs to ${flowerNames[predictedIndex]} with a score of ${confidence.toStringAsFixed(2)}%';
}
  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerSize = size.width * 0.8;
    final cameraSize = scannerSize * 0.9;

    return Scaffold(
      appBar: AppBar(title: const Text("Plant Scanner")),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Flower Scanner",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isCameraInitialized)
                    SizedBox(
                      width: cameraSize,
                      height: cameraSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  SizedBox(
                    width: scannerSize,
                    height: scannerSize,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ScannerFramePainter(
                            scanLineY: (scannerSize * _animationController.value),
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(18),
                child: TextButton(
                  onPressed: () async {
                    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final result = await _classifyImage(pickedFile.path);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Upload from gallery ",
                        style: TextStyle(color: Colors.black),
                      ),
                      Icon(Icons.image),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}