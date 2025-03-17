import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // For TensorFlow Lite
import 'dart:io'; // For File class
import 'package:image/image.dart' as img; // For image processing
import '../custom_widgets/scanner_frame_painter.dart';
import 'flower_result_page.dart'; // Import the new page

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
  bool _isProcessing = false;

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

  Future<Map<String, dynamic>> _classifyImage(String imagePath) async {
    if (_interpreter == null) return {'error': 'Model not loaded'};

    // Load and preprocess the image
    final imageBytes = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    if (image == null) return {'error': 'Failed to decode image'};

    // Resize the image to 180x180
    final resizedImage = img.copyResize(image, width: 180, height: 180);

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
    return _getPrediction(output.cast<List<double>>(), imagePath);
  }
  
  Map<String, dynamic> _getPrediction(List<List<double>> output, String imagePath) {
    final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];

    // Ensure output[0] is not empty
    if (output.isEmpty || output[0].isEmpty) {
      return {'error': 'No prediction available.'};
    }

    // Find the index of the maximum value in output[0]
    final predictedIndex = output[0].indexOf(output[0].reduce((double a, double b) => a > b ? a : b));

    // Calculate confidence percentage
    final confidence = output[0][predictedIndex] * 100;

    // Return the result
    return {
      'flowerName': flowerNames[predictedIndex],
      'confidence': confidence,
      'imagePath': imagePath,
    };
  }
  
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) {
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final XFile picture = await _cameraController!.takePicture();
      final result = await _classifyImage(picture.path);
      
      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
        return;
      }
      
      if (!mounted) return;
      
      // Navigate to result page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlowerResultPage(
            flowerName: result['flowerName'],
            imagePath: result['imagePath'],
            confidence: result['confidence'],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        setState(() => _isProcessing = false);
        return;
      }
      
      final result = await _classifyImage(pickedFile.path);
      
      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
        return;
      }
      
      if (!mounted) return;
      
      // Navigate to result page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlowerResultPage(
            flowerName: result['flowerName'],
            imagePath: result['imagePath'],
            confidence: result['confidence'],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
      appBar: AppBar(
        title: const Text("Plant Scanner"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
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
                  // Floating capture button
                  if (_isCameraInitialized && !_isProcessing)
                    Positioned(
                      bottom: 20,
                      child: GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  // Processing indicator
                  if (_isProcessing)
                    const CircularProgressIndicator(),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickFromGallery,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo_library),
                label: const Text("Choose from gallery"),
              ),
              const SizedBox(height: 20),
              if (!_isModelLoaded)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Loading flower recognition model...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
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