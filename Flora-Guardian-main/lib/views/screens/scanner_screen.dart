// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   static final GlobalKey<_ScannerScreenState> scannerKey = GlobalKey<_ScannerScreenState>();

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen> {
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Flower Scanner")),
//       body: Center(
//         child: _isLoading 
//           ? const CircularProgressIndicator()
//           : ElevatedButton(
//               onPressed: _pickImage,
//               child: const Text("Pick Image & Predict"),
//             ),
//       ),
//     );
//   }

//   /// Select an image and predict
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _isLoading = true;
//       });

//       final file = File(pickedFile.path);
//       final result = await _predictImage(file);

//       setState(() {
//         _isLoading = false;
//       });

//       if (result['success'] == true) {
//         _showResultDialog(result['flowerName'], result['confidence']);
//       } else {
//         _showErrorDialog(result['error']);
//       }
//     }
//   }

//   /// Call the FastAPI endpoint to predict flower
// Future<Map<String, dynamic>> _predictImage(File imageFile) async {
//   try {
//     // Create multipart request
//     var request = http.MultipartRequest(
//       'POST', 
//       Uri.parse('http://127.0.0.1:8000/predict/')
//     );
    
//     // Add the image file to the request
//     request.files.add(
//       await http.MultipartFile.fromPath('file', imageFile.path)
//     );

//     // Send the request
//     var response = await request.send();
    
//     // Read and parse the response
//     var responseBody = await response.stream.bytesToString();
    
//     // Check if the response is successful
//     if (response.statusCode != 200) {
//       return {
//         'success': false,
//         'error': 'Server returned status code ${response.statusCode}: $responseBody'
//       };
//     }

//     var jsonResponse = json.decode(responseBody);

//     // Process the prediction
//     final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
//     final predictions = List<double>.from(jsonResponse['prediction'][0]);
    
//     // Find the highest confidence prediction
//     final predictedIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
//     final confidence = predictions[predictedIndex] * 100;

//     return {
//       'success': true,
//       'flowerName': flowerNames[predictedIndex],
//       'confidence': confidence
//     };
//   } catch (e) {
//     return {
//       'success': false,
//       'error': 'Prediction failed: $e'
//     };
//   }
// }

//   /// Show the result in a popup
//   void _showResultDialog(String flowerName, double confidence) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Prediction Result"),
//           content: Text("Flower: $flowerName\nConfidence: ${confidence.toStringAsFixed(2)}%"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Show error dialog
//   void _showErrorDialog(String error) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Error"),
//           content: Text(error),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../custom_widgets/scanner_frame_painter.dart';
import 'flower_result_page.dart';

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
  bool _isProcessing = false;
  bool _isFlowerMode = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initializeCamera();
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

  Future<Map<String, dynamic>> _predictImage(File imageFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('http://127.0.0.1:8000/predict/')
      );
      
      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path)
      );

      // Send the request
      var response = await request.send();
      
      // Read and parse the response
      var responseBody = await response.stream.bytesToString();
      
      // Check if the response is successful
      if (response.statusCode != 200) {
        return {
          'success': false,
          'error': 'Server returned status code ${response.statusCode}: $responseBody'
        };
      }

      var jsonResponse = json.decode(responseBody);

      // Process the prediction
      final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
      final predictions = List<double>.from(jsonResponse['prediction'][0]);
      
      // Find the highest confidence prediction
      final predictedIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[predictedIndex] * 100;

      return {
        'success': true,
        'flowerName': flowerNames[predictedIndex],
        'confidence': confidence,
        'imagePath': imageFile.path
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Prediction failed: $e'
      };
    }
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
      final result = await _predictImage(File(picture.path));
      
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
      
      final result = await _predictImage(File(pickedFile.path));
      
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
              if (!_isFlowerMode)
                const Padding(
                  padding: EdgeInsets.all(16),
                  // child: Text(
                  //   "Note: Disease detection uses cloud API - internet connection required",
                  //   style: TextStyle(
                  //     color: Colors.grey,
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  // ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}