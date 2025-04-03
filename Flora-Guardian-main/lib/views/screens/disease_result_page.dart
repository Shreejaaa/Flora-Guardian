import 'package:flutter/material.dart';
import 'dart:io';

class DiseaseResultPage extends StatelessWidget {
  final String diseaseName;
  final String plantType;
  final String condition;
  final double confidence;
  final String imagePath;

  const DiseaseResultPage({
    required this.diseaseName,
    required this.plantType,
    required this.condition,
    required this.confidence,
    required this.imagePath,
  });

  // Format disease name for user-friendly display
  String _formatDiseaseNameForDisplay(String name) {
    if (name.isEmpty) return 'Unknown Disease';
    
    // Remove "___" separators and replace with ": "
    String formatted = name;
    if (name.contains('___')) {
      List<String> parts = name.split('___');
      String plantPart = parts[0].replaceAll('_', ' ');
      String diseasePart = parts[1].replaceAll('_', ' ');
      
      // Capitalize words
      plantPart = _capitalizeWords(plantPart);
      diseasePart = _capitalizeWords(diseasePart);
      
      formatted = '$plantPart: $diseasePart';
    } else {
      // Just replace underscores with spaces and capitalize
      formatted = _capitalizeWords(name.replaceAll('_', ' '));
    }
    
    return formatted;
  }

  // Helper to capitalize each word in a string
  String _capitalizeWords(String text) {
    if (text.isEmpty) return '';
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // Enhanced normalization function
  String _normalizeDiseaseName(String name) {
    if (name.isEmpty) return 'unknown';
    
    // First, try to preserve the original format if possible
    if (name.contains('___')) {
      return name.trim();
    }
    
    // Otherwise, perform more aggressive normalization
    String normalized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_ ]'), '') // Remove special chars
        .replaceAll(' ', '_')  // Spaces to underscores
        .trim();
        
    // Check if it contains plant name and condition separated by some delimiter
    List<String> parts = normalized.split(RegExp(r'[_\s-]+'));
    if (parts.length >= 2) {
      String plantName = parts[0];
      // Combine the rest as the condition
      String condition = parts.sublist(1).join('_');
      return '${plantName}___${condition}';
    }
    
    return normalized;
  }

  // Get disease information based on detected disease
  Map<String, dynamic> getDiseaseInfo() {
    debugPrint('==== DISEASE DATA DUMP ====');
    debugPrint('Raw diseaseName: $diseaseName');
    debugPrint('Plant type: $plantType');
    debugPrint('Condition: $condition');
    debugPrint('Confidence: $confidence%');
    
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
    
    // Try multiple approaches to find a match
    
    // 0. Try using the plant type and condition directly if available
    if (plantType.isNotEmpty && condition.isNotEmpty) {
      String constructedKey = '${plantType}___${condition.replaceAll(' ', '_')}';
      debugPrint('Trying constructed key: $constructedKey');
      if (diseaseDatabase.containsKey(constructedKey)) {
        return diseaseDatabase[constructedKey]!;
      }
    }
    
    // 1. Normalize the incoming name
    final normalizedName = _normalizeDiseaseName(diseaseName);
    debugPrint('Normalized name: $normalizedName');
    debugPrint('Available keys: ${diseaseDatabase.keys.join(', ')}');
    
    // 2. Try exact match
    if (diseaseDatabase.containsKey(normalizedName)) {
      return diseaseDatabase[normalizedName]!;
    }
    
    // 3. Try case-insensitive match
    for (final key in diseaseDatabase.keys) {
      if (key.toLowerCase() == normalizedName.toLowerCase()) {
        return diseaseDatabase[key]!;
      }
    }
    
    // 4. Try to match just based on plant type
    if (plantType.isNotEmpty) {
      for (final key in diseaseDatabase.keys) {
        if (key.toLowerCase().startsWith(plantType.toLowerCase())) {
          if (condition.toLowerCase().contains('healthy') && 
              key.toLowerCase().contains('healthy')) {
            return diseaseDatabase[key]!;
          }
          else if (condition.toLowerCase().contains(key.split('___').last.toLowerCase())) {
            return diseaseDatabase[key]!;
          }
        }
      }
    }
    
    // 5. Try keywords matching
    final words = normalizedName.toLowerCase().split(RegExp(r'[_\s]+'));
    for (final key in diseaseDatabase.keys) {
      final keyWords = key.toLowerCase().split(RegExp(r'[_\s]+'));
      // Check if at least half of the words match
      int matches = 0;
      for (final word in words) {
        if (keyWords.contains(word)) {
          matches++;
        }
      }
      if (matches >= words.length / 2) {
        return diseaseDatabase[key]!;
      }
    }
    
    // 6. Try the condition part after last ___
    final conditionPart = normalizedName.split('___').last;
    for (final key in diseaseDatabase.keys) {
      if (key.endsWith(conditionPart)) {
        return diseaseDatabase[key]!;
      }
    }
    
    // 7. Try partial matching
    for (final key in diseaseDatabase.keys) {
      if (normalizedName.contains(key) || key.contains(normalizedName)) {
        return diseaseDatabase[key]!;
      }
    }
    
    return {
      'cause': 'No match found for "$diseaseName" (normalized: "$normalizedName")',
      'treatment': 'Available keys: ${diseaseDatabase.keys.join(', ')}',
      'prevention': 'Check backend response format',
      'color': Colors.orange.shade100,
      'icon': Icons.search_off,
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
                // Disease name on the image - UPDATED to use the formatter
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _formatDiseaseNameForDisplay(diseaseName),
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