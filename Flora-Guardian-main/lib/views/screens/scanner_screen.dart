import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // For TensorFlow Lite
import 'dart:io'; // For File class
import 'package:image/image.dart' as img; // For image processing
import '../custom_widgets/scanner_frame_painter.dart';
import 'flower_result_page.dart'; // Import the flower result page
import 'disease_result_page.dart'; // Import the disease detection page

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

  Interpreter? _flowerInterpreter; // Flower model interpreter
  Interpreter? _diseaseInterpreter; // Disease model interpreter
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  bool _isFlowerMode = true; // Toggle between flower and disease detection

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
      _flowerInterpreter = await Interpreter.fromAsset('assets/flower_recognition.tflite');
      _diseaseInterpreter = await Interpreter.fromAsset('assets/plant_disease_model.tflite');
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
    if (_flowerInterpreter == null) return {'error': 'Model not loaded'};
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
    final output = List.filled(1 * 5, 0.0).reshape([1, 5]); // Adjust based on model output size
    _flowerInterpreter!.run(input, output);
    // Get the prediction
    return _getPrediction(output.cast<List<double>>(), imagePath);
  }

  Map<String, dynamic> _getPrediction(List<List<double>> output, String imagePath) {
    final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
    // Find the index of the maximum value in output[0]
    final predictedIndex =
        output[0].indexOf(output[0].reduce((double a, double b) => a > b ? a : b));
    // Calculate confidence percentage
    final confidence = output[0][predictedIndex] * 100;
    // Return the result
    return {
      'flowerName': flowerNames[predictedIndex],
      'confidence': confidence,
      'imagePath': imagePath,
    };
  }

  Future<Map<String, dynamic>> _classifyDisease(String imagePath) async {
    if (_diseaseInterpreter == null) return {'error': 'Model not loaded'};
    // Load and preprocess the image
    final imageBytes = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    if (image == null) return {'error': 'Failed to decode image'};
    // Resize the image to match the model's input size
    final resizedImage = img.copyResize(image, width: 180, height: 180);
    // Normalize the image pixels
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
    final output = List.filled(1 * 19, 0.0).reshape([1, 19]); // Adjust based on model output size
    _diseaseInterpreter!.run(input, output);
    // Get the prediction
    return _getDiseasePrediction(output.cast<List<double>>());
  }

  Map<String, dynamic> _getDiseasePrediction(List<List<double>> output) {
    final diseaseNames = [
      'Apple___Apple_scab',
      'Apple___Black_rot',
      'Apple___Cedar_apple_rust',
      'Apple___healthy',
      'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
      'Corn_(maize)___Common_rust_',
      'Corn_(maize)___Northern_Leaf_Blight',
      'Corn_(maize)___healthy',
      'Grape___Black_rot',
      'Grape___Esca_(Black_Measles)',
      'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
      'Grape___healthy',
      'Potato___Early_blight',
      'Potato___Late_blight',
      'Potato___healthy',
      'Tomato___Bacterial_spot',
      'Tomato___Leaf_Mold',
      'Tomato___Septoria_leaf_spot',
      'Tomato___healthy'
    ];
    // Find the index of the maximum value in output[0]
    final predictedIndex =
        output[0].indexOf(output[0].reduce((double a, double b) => a > b ? a : b));
    // Calculate confidence percentage
    final confidence = output[0][predictedIndex] * 100;
    return {
      'diseaseName': diseaseNames[predictedIndex],
      'confidence': confidence,
    };
  }

  Future<void> _takePicture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final XFile picture = await _cameraController!.takePicture();
      if (_isFlowerMode) {
        // Flower recognition mode
        final result = await _classifyImage(picture.path);
        if (result.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
          setState(() => _isProcessing = false);
          return;
        }
        if (!mounted) return;
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
      } else {
        // Disease detection mode
        final diseaseResult = await _classifyDisease(picture.path);
        if (diseaseResult.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(diseaseResult['error'])),
          );
          setState(() => _isProcessing = false);
          return;
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseResultPage(
              imagePath: picture.path,
              diseaseName: diseaseResult['diseaseName'],
              confidence: diseaseResult['confidence'],
            ),
          ),
        );
      }
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
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        setState(() => _isProcessing = false);
        return;
      }
      if (_isFlowerMode) {
        // Flower recognition mode
        final result = await _classifyImage(pickedFile.path);
        if (result.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
          setState(() => _isProcessing = false);
          return;
        }
        if (!mounted) return;
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
      } else {
        // Disease detection mode
        final diseaseResult = await _classifyDisease(pickedFile.path);
        if (diseaseResult.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(diseaseResult['error'])),
          );
          setState(() => _isProcessing = false);
          return;
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseResultPage(
              imagePath: pickedFile.path,
              diseaseName: diseaseResult['diseaseName'],
              confidence: diseaseResult['confidence'],
            ),
          ),
        );
      }
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
    _flowerInterpreter?.close();
    _diseaseInterpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerSize = size.width * 0.8;
    final cameraSize = scannerSize * 0.9;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Bar
              AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                centerTitle: false,
                title: Row(
                  children: [
                    Icon(
                      Icons.local_florist,
                      color: Colors.green.shade800,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Flora Guardian",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.green.shade800),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              // Mode toggle switch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Mode: ",
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: _isFlowerMode,
                      onChanged: (value) {
                        setState(() {
                          _isFlowerMode = value;
                        });
                      },
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade100,
                      inactiveThumbColor: Colors.orange,
                      inactiveTrackColor: Colors.orange.shade100,
                    ),
                    Text(
                      _isFlowerMode ? "Flower Recognition" : "Disease Detection",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isFlowerMode ? "Flower Scanner" : "Plant Disease Scanner",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            color: _isFlowerMode ? Colors.green : Colors.orange,
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
                            border: Border.all(
                              color:
                                  _isFlowerMode ? Colors.green : Colors.orange,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: _isFlowerMode
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ),
                  // Processing indicator
                  if (_isProcessing)
                    CircularProgressIndicator(
                      color: _isFlowerMode ? Colors.green : Colors.orange,
                    ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickFromGallery,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: _isFlowerMode
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
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
              if (!_isFlowerMode && !_isModelLoaded)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Note: Disease detection uses cloud API - internet connection required",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (_isFlowerMode && !_isModelLoaded)
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