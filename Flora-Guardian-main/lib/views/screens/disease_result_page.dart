import 'package:flutter/material.dart';
import 'dart:io';

class DiseaseResultPage extends StatelessWidget {
  final String imagePath;
  final String diseaseName;
  final double confidence;

  const DiseaseResultPage({
    super.key,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
  });

  // Get disease information based on detected disease
  Map<String, dynamic> getDiseaseInfo() {
    final diseaseDatabase = {
      'Apple___Apple_scab': {
        'cause': 'Fungal infection caused by Venturia inaequalis',
        'treatment': 'Apply fungicides like myclobutanil or sulfur-based sprays.',
        'prevention': 'Prune infected leaves and ensure good air circulation.',
        'color': Colors.red.shade100,
        'icon': Icons.warning_amber_outlined,
      },
      'Apple___Black_rot': {
        'cause': 'Fungal infection caused by Botryosphaeria obtusa',
        'treatment': 'Remove infected fruits and apply copper-based fungicides.',
        'prevention': 'Avoid overhead watering and prune regularly.',
        'color': Colors.red.shade200,
        'icon': Icons.bug_report,
      },
      'Apple___Cedar_apple_rust': {
        'cause': 'Fungal infection caused by Gymnosporangium juniperi-virginianae',
        'treatment': 'Use fungicides containing myclobutanil.',
        'prevention': 'Remove nearby cedar trees and prune infected branches.',
        'color': Colors.orange.shade100,
        'icon': Icons.eco_outlined,
      },
      'Apple___healthy': {
        'cause': 'No disease detected',
        'treatment': 'No treatment needed.',
        'prevention': 'Maintain regular care practices.',
        'color': Colors.green.shade100,
        'icon': Icons.check_circle_outline,
      },
      'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot': {
        'cause': 'Fungal infection caused by Cercospora zeae-maydis',
        'treatment': 'Apply strobilurin fungicides.',
        'prevention': 'Rotate crops and avoid planting corn in the same field consecutively.',
        'color': Colors.red.shade100,
        'icon': Icons.warning_amber_outlined,
      },
      'Corn_(maize)___Common_rust_': {
        'cause': 'Fungal infection caused by Puccinia sorghi',
        'treatment': 'Use fungicides like azoxystrobin or pyraclostrobin.',
        'prevention': 'Plant resistant varieties and avoid excessive nitrogen fertilization.',
        'color': Colors.red.shade200,
        'icon': Icons.bug_report,
      },
      'Corn_(maize)___Northern_Leaf_Blight': {
        'cause': 'Fungal infection caused by Exserohilum turcicum',
        'treatment': 'Apply triazole fungicides.',
        'prevention': 'Practice crop rotation and use resistant hybrids.',
        'color': Colors.orange.shade100,
        'icon': Icons.eco_outlined,
      },
      'Corn_(maize)___healthy': {
        'cause': 'No disease detected',
        'treatment': 'No treatment needed.',
        'prevention': 'Maintain regular care practices.',
        'color': Colors.green.shade100,
        'icon': Icons.check_circle_outline,
      },
      'Grape___Black_rot': {
        'cause': 'Fungal infection caused by Guignardia bidwellii',
        'treatment': 'Apply fungicides like mancozeb or captan.',
        'prevention': 'Remove infected leaves and fruit mummies.',
        'color': Colors.red.shade100,
        'icon': Icons.warning_amber_outlined,
      },
      'Grape___Esca_(Black_Measles)': {
        'cause': 'Complex of fungal pathogens including Phaeomoniella chlamydospora',
        'treatment': 'No effective chemical treatments available.',
        'prevention': 'Remove infected vines and practice proper pruning.',
        'color': Colors.red.shade200,
        'icon': Icons.bug_report,
      },
      'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': {
        'cause': 'Fungal infection caused by Isariopsis leaf spot fungus',
        'treatment': 'Apply fungicides like chlorothalonil.',
        'prevention': 'Ensure good air circulation and avoid overhead irrigation.',
        'color': Colors.orange.shade100,
        'icon': Icons.eco_outlined,
      },
      'Grape___healthy': {
        'cause': 'No disease detected',
        'treatment': 'No treatment needed.',
        'prevention': 'Maintain regular care practices.',
        'color': Colors.green.shade100,
        'icon': Icons.check_circle_outline,
      },
      'Potato___Early_blight': {
        'cause': 'Fungal infection caused by Alternaria solani',
        'treatment': 'Apply fungicides like chlorothalonil or mancozeb.',
        'prevention': 'Rotate crops and avoid overhead watering.',
        'color': Colors.red.shade100,
        'icon': Icons.warning_amber_outlined,
      },
      'Potato___Late_blight': {
        'cause': 'Fungal infection caused by Phytophthora infestans',
        'treatment': 'Apply fungicides like metalaxyl or dimethomorph.',
        'prevention': 'Destroy infected plants and avoid planting in wet areas.',
        'color': Colors.red.shade200,
        'icon': Icons.bug_report,
      },
      'Potato___healthy': {
        'cause': 'No disease detected',
        'treatment': 'No treatment needed.',
        'prevention': 'Maintain regular care practices.',
        'color': Colors.green.shade100,
        'icon': Icons.check_circle_outline,
      },
      'Tomato___Bacterial_spot': {
        'cause': 'Bacterial infection caused by Xanthomonas campestris',
        'treatment': 'No effective chemical treatments available.',
        'prevention': 'Use disease-free seeds and rotate crops.',
        'color': Colors.red.shade100,
        'icon': Icons.warning_amber_outlined,
      },
      'Tomato___Leaf_Mold': {
        'cause': 'Fungal infection caused by Passalora fulva',
        'treatment': 'Apply fungicides like chlorothalonil.',
        'prevention': 'Ensure good ventilation and avoid overhead watering.',
        'color': Colors.orange.shade100,
        'icon': Icons.eco_outlined,
      },
      'Tomato___Septoria_leaf_spot': {
        'cause': 'Fungal infection caused by Septoria lycopersici',
        'treatment': 'Apply fungicides like chlorothalonil or mancozeb.',
        'prevention': 'Remove infected leaves and practice crop rotation.',
        'color': Colors.orange.shade100,
        'icon': Icons.eco_outlined,
      },
      'Tomato___healthy': {
        'cause': 'No disease detected',
        'treatment': 'No treatment needed.',
        'prevention': 'Maintain regular care practices.',
        'color': Colors.green.shade100,
        'icon': Icons.check_circle_outline,
      },
    };
    return diseaseDatabase[diseaseName] ?? {
      'cause': 'Unknown cause',
      'treatment': 'Information not available',
      'prevention': 'Information not available',
      'color': Colors.grey.shade100,
      'icon': Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final diseaseInfo = getDiseaseInfo();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flora Guardian'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Disease image with animated gradient overlay
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: screenSize.height * 0.4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Disease name on the image
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    diseaseName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Disease information in boxes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disease Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cause box
                  _buildInfoBox(
                    title: 'Cause',
                    content: diseaseInfo['cause'],
                    icon: Icons.info_outline,
                    color: diseaseInfo['color'],
                  ),
                  // Treatment box
                  _buildInfoBox(
                    title: 'Treatment',
                    content: diseaseInfo['treatment'],
                    icon: Icons.healing,
                    color: Colors.blue.shade100,
                  ),
                  // Prevention box
                  _buildInfoBox(
                    title: 'Prevention',
                    content: diseaseInfo['prevention'],
                    icon: Icons.health_and_safety,
                    color: Colors.teal.shade100,
                  ),
                  const SizedBox(height: 30),
                  // Tip box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.green.shade700),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pro Tip',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Monitor your plants regularly and take action at the first sign of disease.',
                                style: TextStyle(color: Colors.green.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: diseaseInfo['color'],
        child: const Icon(Icons.camera_alt, color: Colors.black54),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // For ripple effect
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 28, color: Colors.black54),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}