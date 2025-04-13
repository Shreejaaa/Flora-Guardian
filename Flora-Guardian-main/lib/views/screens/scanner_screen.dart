// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:convert';
// import '../custom_widgets/scanner_frame_painter.dart';
// import 'flower_result_page.dart';
// import 'disease_result_page.dart'; // Import the disease result page

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   CameraController? _cameraController;
//   bool _isCameraInitialized = false;
//   bool _isProcessing = false;
//   bool _isFlowerMode = true;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty) return;
//       _cameraController = CameraController(
//         cameras.first,
//         ResolutionPreset.medium,
//       );
//       await _cameraController!.initialize();
//       if (mounted) {
//         setState(() => _isCameraInitialized = true);
//       }
//     } catch (e) {
//       debugPrint('Camera initialization error: $e');
//     }
//   }

//   Future<Map<String, dynamic>> _predictFlower(File imageFile) async {
//     try {
//       // Create multipart request
//       var request = http.MultipartRequest(
//         'POST', 
//         Uri.parse('http://192.168.1.177:8000/predict/')
//       );
      
//       // Add the image file to the request
//       request.files.add(
//         await http.MultipartFile.fromPath('file', imageFile.path)
//       );

//       // Send the request
//       var response = await request.send();
      
//       // Read and parse the response
//       var responseBody = await response.stream.bytesToString();
      
//       // Check if the response is successful
//       if (response.statusCode != 200) {
//         return {
//           'success': false,
//           'error': 'Server returned status code ${response.statusCode}: $responseBody'
//         };
//       }

//       var jsonResponse = json.decode(responseBody);

//       // Process the prediction
//       final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
//       final predictions = List<double>.from(jsonResponse['prediction'][0]);
      
//       // Find the highest confidence prediction
//       final predictedIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
//       final confidence = predictions[predictedIndex] * 100;

//       return {
//         'success': true,
//         'flowerName': flowerNames[predictedIndex],
//         'confidence': confidence,
//         'imagePath': imageFile.path
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Prediction failed: $e'
//       };
//     }
//   }

//   Future<Map<String, dynamic>> _predictDisease(File imageFile) async {
//   try {
//     var request = http.MultipartRequest(
//       'POST', 
//       Uri.parse('http://192.168.1.177:8001/predict-disease/'),
//     );
    
//     request.files.add(
//       await http.MultipartFile.fromPath('file', imageFile.path)
//     );

//     var response = await request.send();
//     var responseBody = await response.stream.bytesToString();
//     print('RAW DISEASE API RESPONSE: $responseBody'); // Critical debug line
    
//     var jsonResponse = json.decode(responseBody);

//     // Enhanced error handling
//     if (response.statusCode != 200) {
//       throw 'HTTP ${response.statusCode} - ${response.reasonPhrase}';
//     }

//     // Handle both possible response formats
//     final diseaseName = jsonResponse['disease_name'] ?? 
//                        jsonResponse['full_class_name'] ?? 
//                        'UNKNOWN_ERROR';

//     return {
//       'success': jsonResponse['success'] ?? false,
//       'diseaseName': diseaseName,
//       'plantType': jsonResponse['plant_type'] ?? 'Unknown',
//       'condition': jsonResponse['condition'] ?? 'Unknown',
//       'confidence': (jsonResponse['confidence'] ?? 0).toDouble(),
//       'imagePath': imageFile.path,
//       'rawResponse': jsonResponse // For debugging
//     };
//   } catch (e) {
//     return {
//       'success': false,
//       'error': 'Prediction failed: ${e.toString()}'
//     };
//   }
// }

//   Future<void> _takePicture() async {
//     if (_cameraController == null ||
//         !_cameraController!.value.isInitialized ||
//         _isProcessing) {
//       return;
//     }
//     setState(() => _isProcessing = true);
//     try {
//       final XFile picture = await _cameraController!.takePicture();
      
//       if (_isFlowerMode) {
//         // Process as flower
//         final result = await _predictFlower(File(picture.path));
        
//         if (result.containsKey('error')) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(result['error'])),
//           );
//           setState(() => _isProcessing = false);
//           return;
//         }
        
//         if (!mounted) return;
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FlowerResultPage(
//               flowerName: result['flowerName'],
//               imagePath: result['imagePath'],
//               confidence: result['confidence'],
//             ),
//           ),
//         );
//       } else {
//         // Process as disease
//         final result = await _predictDisease(File(picture.path));
        
//         if (result.containsKey('error')) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(result['error'])),
//           );
//           setState(() => _isProcessing = false);
//           return;
//         }
        
//         if (!mounted) return;
//         Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => DiseaseResultPage(
//       diseaseName: result['diseaseName'] ?? 'Unknown',
//       plantType: result['plantType'] ?? 'Unknown',
//       condition: result['condition'] ?? 'Unknown',
//       imagePath: result['imagePath'],
//       confidence: result['confidence'] ?? 0.0,
//     ),
//   ),
// );
//       }
//     } catch (e) {
//       debugPrint('Error taking picture: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error capturing image: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   Future<void> _pickFromGallery() async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);
//     try {
//       final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile == null) {
//         setState(() => _isProcessing = false);
//         return;
//       }
      
//       if (_isFlowerMode) {
//         // Process as flower
//         final result = await _predictFlower(File(pickedFile.path));
        
//         if (result.containsKey('error')) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(result['error'])),
//           );
//           setState(() => _isProcessing = false);
//           return;
//         }
        
//         if (!mounted) return;
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FlowerResultPage(
//               flowerName: result['flowerName'],
//               imagePath: result['imagePath'],
//               confidence: result['confidence'],
//             ),
//           ),
//         );
//       } else {
//         // Process as disease
//         final result = await _predictDisease(File(pickedFile.path));
        
//         if (result.containsKey('error')) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(result['error'])),
//           );
//           setState(() => _isProcessing = false);
//           return;
//         }
        
//         if (!mounted) return;
//         Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => DiseaseResultPage(
//       diseaseName: result['diseaseName'] ?? 'Unknown',
//       plantType: result['plantType'] ?? 'Unknown',
//       condition: result['condition'] ?? 'Unknown',
//       imagePath: result['imagePath'],
//       confidence: result['confidence'] ?? 0.0,
//     ),
//   ),
// );
//       }
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting image: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final scannerSize = size.width * 0.8;
//     final cameraSize = scannerSize * 0.9;
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               _isFlowerMode ? Colors.green.shade50 : Colors.orange.shade50,
//               Colors.white,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // App Bar
//               AppBar(
//                 elevation: 0,
//                 backgroundColor: Colors.transparent,
//                 centerTitle: false,
//                 title: Row(
//                   children: [
//                     Icon(
//                       Icons.local_florist,
//                       color: _isFlowerMode ? Colors.green.shade800 : Colors.orange.shade800,
//                       size: 28,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       "Flora Guardian",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: _isFlowerMode ? Colors.green.shade800 : Colors.orange.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   IconButton(
//                     icon: Icon(
//                       Icons.info_outline, 
//                       color: _isFlowerMode ? Colors.green.shade800 : Colors.orange.shade800
//                     ),
//                     onPressed: () {},
//                   ),
//                   const SizedBox(width: 16),
//                 ],
//               ),
//               // Mode toggle switch
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Mode: ",
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     Switch(
//                       value: _isFlowerMode,
//                       onChanged: (value) {
//                         setState(() {
//                           _isFlowerMode = value;
//                         });
//                       },
//                       activeColor: Colors.green,
//                       activeTrackColor: Colors.green.shade100,
//                       inactiveThumbColor: Colors.orange,
//                       inactiveTrackColor: Colors.orange.shade100,
//                     ),
//                     Text(
//                       _isFlowerMode ? "Flower Recognition" : "Disease Detection",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 _isFlowerMode ? "Flower Scanner" : "Plant Disease Scanner",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   if (_isCameraInitialized)
//                     SizedBox(
//                       width: cameraSize,
//                       height: cameraSize,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: CameraPreview(_cameraController!),
//                       ),
//                     ),
//                   SizedBox(
//                     width: scannerSize,
//                     height: scannerSize,
//                     child: AnimatedBuilder(
//                       animation: _animationController,
//                       builder: (context, child) {
//                         return CustomPaint(
//                           painter: ScannerFramePainter(
//                             scanLineY: (scannerSize * _animationController.value),
//                             color: _isFlowerMode ? Colors.green : Colors.orange,
//                           ),
//                           child: Container(),
//                         );
//                       },
//                     ),
//                   ),
//                   // Floating capture button
//                   if (_isCameraInitialized && !_isProcessing)
//                     Positioned(
//                       bottom: 20,
//                       child: GestureDetector(
//                         onTap: _takePicture,
//                         child: Container(
//                           width: 70,
//                           height: 70,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.8),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color:
//                                   _isFlowerMode ? Colors.green : Colors.orange,
//                               width: 3,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             Icons.camera_alt,
//                             size: 36,
//                             color: _isFlowerMode
//                                 ? Colors.green.shade800
//                                 : Colors.orange.shade800,
//                           ),
//                         ),
//                       ),
//                     ),
//                   // Processing indicator
//                   if (_isProcessing)
//                     CircularProgressIndicator(
//                       color: _isFlowerMode ? Colors.green : Colors.orange,
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton.icon(
//                 onPressed: _isProcessing ? null : _pickFromGallery,
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   backgroundColor: _isFlowerMode
//                       ? Colors.green.shade100
//                       : Colors.orange.shade100,
//                   foregroundColor: Colors.black87,
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 icon: const Icon(Icons.photo_library),
//                 label: const Text("Choose from gallery"),
//               ),
//               const SizedBox(height: 20),
//               if (!_isFlowerMode)
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     "Note: Disease detection works best with clear, well-lit images of plant leaves",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontStyle: FontStyle.italic,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ------------------------------------

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:convert';
// import 'flower_result_page.dart';
// import 'disease_result_page.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen> {
//   bool _isProcessing = false;
//   bool _isFlowerMode = true;

//   Future<Map<String, dynamic>> _predictFlower(File imageFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('http://192.168.1.177:8000/predict/'),

//       );
//       request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();

//       if (response.statusCode != 200) {
//         return {
//           'success': false,
//           'error': 'Server error ${response.statusCode}: $responseBody',
//         };
//       }

//       var jsonResponse = json.decode(responseBody);
//       final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
//       final predictions = List<double>.from(jsonResponse['prediction'][0]);
//       final predictedIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
//       final confidence = predictions[predictedIndex] * 100;

//       return {
//         'success': true,
//         'flowerName': flowerNames[predictedIndex],
//         'confidence': confidence,
//         'imagePath': imageFile.path,
//       };
//     } catch (e) {
//       return {'success': false, 'error': 'Prediction failed: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> _predictDisease(File imageFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//        Uri.parse('http://192.168.1.177:8001/predict-disease/'),

//       );
//       request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseBody);

//       if (response.statusCode != 200) {
//         throw 'HTTP ${response.statusCode} - ${response.reasonPhrase}';
//       }

//       final diseaseName = jsonResponse['disease_name'] ??
//           jsonResponse['full_class_name'] ??
//           'UNKNOWN_ERROR';

//       return {
//         'success': jsonResponse['success'] ?? false,
//         'diseaseName': diseaseName,
//         'plantType': jsonResponse['plant_type'] ?? 'Unknown',
//         'condition': jsonResponse['condition'] ?? 'Unknown',
//         'confidence': (jsonResponse['confidence'] ?? 0).toDouble(),
//         'imagePath': imageFile.path,
//         'rawResponse': jsonResponse,
//       };
//     } catch (e) {
//       return {'success': false, 'error': 'Prediction failed: $e'};
//     }
//   }

//   Future<void> _pickFromGallery() async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);
//     try {
//       final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile == null) {
//         setState(() => _isProcessing = false);
//         return;
//       }

//       final File imageFile = File(pickedFile.path);
//       final result = _isFlowerMode
//           ? await _predictFlower(imageFile)
//           : await _predictDisease(imageFile);

//       if (result.containsKey('error')) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result['error'])),
//         );
//         setState(() => _isProcessing = false);
//         return;
//       }

//       if (!mounted) return;
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => _isFlowerMode
//               ? FlowerResultPage(
//                   flowerName: result['flowerName'],
//                   imagePath: result['imagePath'],
//                   confidence: result['confidence'],
//                 )
//               : DiseaseResultPage(
//                   diseaseName: result['diseaseName'] ?? 'Unknown',
//                   plantType: result['plantType'] ?? 'Unknown',
//                   condition: result['condition'] ?? 'Unknown',
//                   imagePath: result['imagePath'],
//                   confidence: result['confidence'] ?? 0.0,
//                 ),
//         ),
//       );
//     } catch (e) {
//       debugPrint('Image pick error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting image: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Flora Guardian"),
//         backgroundColor: _isFlowerMode ? Colors.green : Colors.orange,
//         actions: [
//           Switch(
//             value: _isFlowerMode,
//             onChanged: (value) => setState(() => _isFlowerMode = value),
//             activeColor: Colors.white,
//             activeTrackColor: Colors.greenAccent,
//             inactiveThumbColor: Colors.orange,
//             inactiveTrackColor: Colors.orangeAccent,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _isFlowerMode ? "Flower Recognition" : "Disease Detection",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton.icon(
//                 onPressed: _isProcessing ? null : _pickFromGallery,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isFlowerMode
//                       ? Colors.green.shade100
//                       : Colors.orange.shade100,
//                   foregroundColor: Colors.black87,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 ),
//                 icon: const Icon(Icons.photo_library),
//                 label: const Text("Upload Image"),
//               ),
//               if (_isProcessing) ...[
//                 const SizedBox(height: 30),
//                 CircularProgressIndicator(
//                   color: _isFlowerMode ? Colors.green : Colors.orange,
//                 ),
//               ],
//               const SizedBox(height: 20),
//               if (!_isFlowerMode)
//                 const Text(
//                   "Tip: Use clear, close-up images of leaves for better detection.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:convert';
// import 'flower_result_page.dart';
// import 'disease_result_page.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen> {
//   bool _isProcessing = false;
//   bool _isFlowerMode = true;

//   // 🆕 Common method to predict result based on mode
//   Future<void> _processImage(File imageFile) async {
//     setState(() => _isProcessing = true);
//     final result = _isFlowerMode
//         ? await _predictFlower(imageFile)
//         : await _predictDisease(imageFile);

//     if (result.containsKey('error')) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['error'])),
//       );
//       setState(() => _isProcessing = false);
//       return;
//     }

//     if (!mounted) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => _isFlowerMode
//             ? FlowerResultPage(
//                 flowerName: result['flowerName'],
//                 imagePath: result['imagePath'],
//                 confidence: result['confidence'],
//               )
//             : DiseaseResultPage(
//                 diseaseName: result['diseaseName'] ?? 'Unknown',
//                 plantType: result['plantType'] ?? 'Unknown',
//                 condition: result['condition'] ?? 'Unknown',
//                 imagePath: result['imagePath'],
//                 confidence: result['confidence'] ?? 0.0,
//               ),
//       ),
//     );
//     setState(() => _isProcessing = false);
//   }

//   // ✅ GALLERY PICKER
//   Future<void> _pickFromGallery() async {
//     if (_isProcessing) return;
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       await _processImage(File(pickedFile.path));
//     }
//   }

//   // ✅ CAMERA CAPTURE (FOR iPhone)
//   Future<void> _captureFromCamera() async {
//     if (_isProcessing) return;
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       await _processImage(File(pickedFile.path));
//     }
//   }

//   // 🧠 Flower Prediction API
//   Future<Map<String, dynamic>> _predictFlower(File imageFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('http://192.168.1.177:8000/predict/'),
//       );
//       request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();

//       if (response.statusCode != 200) {
//         return {'success': false, 'error': 'Server error ${response.statusCode}: $responseBody'};
//       }

//       var jsonResponse = json.decode(responseBody);
//       final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
//       final predictions = List<double>.from(jsonResponse['prediction'][0]);
//       final predictedIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
//       final confidence = predictions[predictedIndex] * 100;

//       return {
//         'success': true,
//         'flowerName': flowerNames[predictedIndex],
//         'confidence': confidence,
//         'imagePath': imageFile.path,
//       };
//     } catch (e) {
//       return {'success': false, 'error': 'Prediction failed: $e'};
//     }
//   }

//   // 🧠 Disease Prediction API
//   Future<Map<String, dynamic>> _predictDisease(File imageFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('http://192.168.1.177:8001/predict-disease/'),
//       );
//       request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseBody);

//       if (response.statusCode != 200) {
//         throw 'HTTP ${response.statusCode} - ${response.reasonPhrase}';
//       }

//       final diseaseName = jsonResponse['disease_name'] ??
//           jsonResponse['full_class_name'] ??
//           'UNKNOWN_ERROR';

//       return {
//         'success': jsonResponse['success'] ?? false,
//         'diseaseName': diseaseName,
//         'plantType': jsonResponse['plant_type'] ?? 'Unknown',
//         'condition': jsonResponse['condition'] ?? 'Unknown',
//         'confidence': (jsonResponse['confidence'] ?? 0).toDouble(),
//         'imagePath': imageFile.path,
//         'rawResponse': jsonResponse,
//       };
//     } catch (e) {
//       return {'success': false, 'error': 'Prediction failed: $e'};
//     }
//   }

//   // UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Flora Guardian"),
//         backgroundColor: _isFlowerMode ? Colors.green : Colors.orange,
//         actions: [
//           Switch(
//             value: _isFlowerMode,
//             onChanged: (value) => setState(() => _isFlowerMode = value),
//             activeColor: Colors.white,
//             activeTrackColor: Colors.greenAccent,
//             inactiveThumbColor: Colors.orange,
//             inactiveTrackColor: Colors.orangeAccent,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _isFlowerMode ? "Flower Recognition" : "Disease Detection",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton.icon(
//                 onPressed: _isProcessing ? null : _pickFromGallery,
//                 icon: Icon(Icons.photo_library),
//                 label: Text("Upload from Gallery"),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: _isProcessing ? null : _captureFromCamera,
//                 icon: Icon(Icons.camera_alt),
//                 label: Text("Take Photo"),
//               ),
//               if (_isProcessing) ...[
//                 const SizedBox(height: 30),
//                 CircularProgressIndicator(
//                   color: _isFlowerMode ? Colors.green : Colors.orange,
//                 ),
//               ],
//               const SizedBox(height: 20),
//               if (!_isFlowerMode)
//                 const Text(
//                   "Tip: Use clear, close-up images of leaves for better detection.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'flower_result_page.dart';
import 'disease_result_page.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isProcessing = false;
  bool _isFlowerMode = true;
  File? _previewImage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Common method to process images
  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _previewImage = imageFile;
    });
    
    try {
      final result = _isFlowerMode
          ? await _predictFlower(imageFile)
          : await _predictDisease(imageFile);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
        return;
      }

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _isFlowerMode
              ? FlowerResultPage(
                  flowerName: result['flowerName'],
                  imagePath: result['imagePath'],
                  confidence: result['confidence'],
                )
              : DiseaseResultPage(
                  diseaseName: result['diseaseName'] ?? 'Unknown',
                  plantType: result['plantType'] ?? 'Unknown',
                  condition: result['condition'] ?? 'Unknown',
                  imagePath: result['imagePath'],
                  confidence: result['confidence'] ?? 0.0,
                ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Take photo with camera
  Future<void> _takePicture() async {
    if (_isProcessing) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );
    
    if (photo != null) {
      await _processImage(File(photo.path));
    }
  }

  // Pick from gallery
  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    
    if (image != null) {
      await _processImage(File(image.path));
    }
  }

  // Flower prediction API
  Future<Map<String, dynamic>> _predictFlower(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.22.16.199:8000/predict/'), //change according to connectivity
      );
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        return {'success': false, 'error': 'Server error ${response.statusCode}: $responseBody'};
      }

      var jsonResponse = json.decode(responseBody);
      final flowerNames = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower'];
      final predictions = List<double>.from(jsonResponse['prediction'][0]);
      final predictedIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[predictedIndex] * 100;

      return {
        'success': true,
        'flowerName': flowerNames[predictedIndex],
        'confidence': confidence,
        'imagePath': imageFile.path,
      };
    } catch (e) {
      return {'success': false, 'error': 'Prediction failed: $e'};
    }
  }

  // Disease prediction API
  Future<Map<String, dynamic>> _predictDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.22.16.199:8001/predict-disease/'), //change according to connectivity
      );
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode != 200) {
        throw 'HTTP ${response.statusCode} - ${response.reasonPhrase}';
      }

      final diseaseName = jsonResponse['disease_name'] ??
          jsonResponse['full_class_name'] ??
          'UNKNOWN_ERROR';

      return {
        'success': jsonResponse['success'] ?? false,
        'diseaseName': diseaseName,
        'plantType': jsonResponse['plant_type'] ?? 'Unknown',
        'condition': jsonResponse['condition'] ?? 'Unknown',
        'confidence': (jsonResponse['confidence'] ?? 0).toDouble(),
        'imagePath': imageFile.path,
      };
    } catch (e) {
      return {'success': false, 'error': 'Prediction failed: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Make scanner smaller to prevent overflow
    final scannerSize = size.width * 0.75;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isFlowerMode ? Colors.green.shade50 : Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(  // Added ScrollView to prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        color: _isFlowerMode ? Colors.green.shade800 : Colors.orange.shade800,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Flora Guardian",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isFlowerMode ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.info_outline, 
                        color: _isFlowerMode ? Colors.green.shade800 : Colors.orange.shade800
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                
                // Mode toggle switch
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                
                const SizedBox(height: 5),
                Text(
                  _isFlowerMode ? "Flower Scanner" : "Plant Disease Scanner",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                
                // Scanner preview area
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: scannerSize,
                      height: scannerSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isFlowerMode ? Colors.green : Colors.orange,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isFlowerMode ? Colors.green : Colors.orange).withOpacity(0.2 * _animationController.value),
                            spreadRadius: 3 * _animationController.value,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background or image preview
                            _previewImage != null
                                ? Image.file(
                                    _previewImage!,
                                    width: scannerSize,
                                    height: scannerSize,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.black.withOpacity(0.05),
                                    child: Center(
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 80,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                            
                            // Scanning effect
                            if (!_isProcessing && _previewImage == null)
                              Positioned(
                                top: scannerSize * _animationController.value - 10,
                                child: Container(
                                  width: scannerSize - 20,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: _isFlowerMode ? Colors.green : Colors.orange,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isFlowerMode ? Colors.green : Colors.orange).withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                            // Corner scanners
                            Positioned(
                              top: 0,
                              left: 0,
                              child: _buildCorner(topLeft: true),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: _buildCorner(topRight: true),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: _buildCorner(bottomLeft: true),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: _buildCorner(bottomRight: true),
                            ),
                            
                            // Processing indicator
                            if (_isProcessing)
                              Container(
                                color: Colors.black.withOpacity(0.3),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _isFlowerMode ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.photo_library,
                      label: "Gallery",
                      onPressed: _pickFromGallery,
                    ),
                    const SizedBox(width: 40),
                    _buildActionButton(
                      icon: Icons.camera_alt,
                      label: "Camera",
                      onPressed: _takePicture,
                      primary: true,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Helpful tip
                if (!_isFlowerMode)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Tip: Disease detection works best with clear, well-lit images of plant leaves",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                // Extra padding at bottom to ensure no overflow
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to build corner scanners
  Widget _buildCorner({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: 24, // Made smaller
      height: 24, // Made smaller
      child: Stack(
        children: [
          if (topLeft || bottomLeft)
            Positioned(
              left: 0,
              top: topLeft ? 0 : null,
              bottom: bottomLeft ? 0 : null,
              child: Container(
                width: 8, // Made smaller
                height: 2,
                color: _isFlowerMode ? Colors.green : Colors.orange,
              ),
            ),
          if (topLeft || topRight)
            Positioned(
              top: 0,
              left: topLeft ? 0 : null,
              right: topRight ? 0 : null,
              child: Container(
                width: 2,
                height: 8, // Made smaller
                color: _isFlowerMode ? Colors.green : Colors.orange,
              ),
            ),
          if (topRight || bottomRight)
            Positioned(
              right: 0,
              top: topRight ? 0 : null,
              bottom: bottomRight ? 0 : null,
              child: Container(
                width: 8, // Made smaller
                height: 2,
                color: _isFlowerMode ? Colors.green : Colors.orange,
              ),
            ),
          if (bottomLeft || bottomRight)
            Positioned(
              bottom: 0,
              left: bottomLeft ? 0 : null,
              right: bottomRight ? 0 : null,
              child: Container(
                width: 2,
                height: 8, // Made smaller
                color: _isFlowerMode ? Colors.green : Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper method to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    final Color color = _isFlowerMode ? Colors.green : Colors.orange;
    
    return GestureDetector(
      onTap: _isProcessing ? null : onPressed,
      child: Opacity(
        opacity: _isProcessing ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              width: primary ? 65 : 55, // Made smaller
              height: primary ? 65 : 55, // Made smaller
              decoration: BoxDecoration(
                color: primary ? color : color.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: primary ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
              child: Icon(
                icon,
                size: primary ? 28 : 22, // Made smaller
                color: primary ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13, // Made smaller
                fontWeight: primary ? FontWeight.bold : FontWeight.normal,
                color: primary ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}