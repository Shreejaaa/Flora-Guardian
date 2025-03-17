import 'package:flutter/material.dart';
import 'dart:io';

class FlowerResultPage extends StatelessWidget {
  final String flowerName;
  final String imagePath;
  final double confidence;

  const FlowerResultPage({
    super.key,
    required this.flowerName,
    required this.imagePath,
    required this.confidence,
  });

  // Get flower care information based on species
  Map<String, dynamic> getFlowerInfo() {
    // You would ideally store this in a database or fetch from an API
    final flowerDatabase = {
      'daisy': {
        'water': '2-3 times per week',
        'soil': 'Well-draining soil with organic matter',
        'humidity': 'Medium (40-60%)',
        'color': Colors.yellow.shade100,
        'icon': Icons.water_drop_outlined,
      },
      'dandelion': {
        'water': 'Once per week',
        'soil': 'Almost any soil type',
        'humidity': 'Low (30-40%)',
        'color': Colors.yellow.shade200,
        'icon': Icons.eco_outlined,
      },
      'iris': {
        'water': '1-2 times per week',
        'soil': 'Moist, rich soil',
        'humidity': 'Medium-high (50-70%)',
        'color': Colors.purple.shade100,
        'icon': Icons.water_drop,
      },
      'rose': {
        'water': '3 times per week',
        'soil': 'Loamy, well-draining soil',
        'humidity': 'Medium (40-60%)',
        'color': Colors.pink.shade100,
        'icon': Icons.favorite,
      },
      'sunflower': {
        'water': '1-2 times per week',
        'soil': 'Nutrient-rich, well-draining soil',
        'humidity': 'Low to medium (30-50%)',
        'color': Colors.amber.shade100,
        'icon': Icons.wb_sunny_outlined,
      },
    };

    return flowerDatabase[flowerName.toLowerCase()] ?? {
      'water': 'Information not available',
      'soil': 'Information not available',
      'humidity': 'Information not available',
      'color': Colors.grey.shade100,
      'icon': Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final flowerInfo = getFlowerInfo();
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
            // Flower image with animated gradient overlay
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
                        // ignore: deprecated_member_use
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
                // Confidence indicator
                // Positioned(
                //   top: 20,
                //   right: 20,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.7),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Text(
                //       'Confidence: ${confidence.toStringAsFixed(1)}%',
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                // Gradient overlay at the bottom
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
                // Flower name on the image
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    flowerName.toUpperCase(),
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
            
            // Care instructions in boxes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Care Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Species box
                  _buildInfoBox(
                    title: 'Species',
                    content: flowerName,
                    icon: Icons.local_florist,
                    color: flowerInfo['color'],
                  ),
                  
                  // Water needs box
                  _buildInfoBox(
                    title: 'Water Needs',
                    content: flowerInfo['water'],
                    icon: Icons.water_drop,
                    color: Colors.blue.shade100,
                  ),
                  
                  // Soil type box
                  _buildInfoBox(
                    title: 'Soil Type',
                    content: flowerInfo['soil'],
                    icon: Icons.landscape,
                    color: Colors.brown.shade100,
                  ),
                  
                  // Humidity box
                  _buildInfoBox(
                    title: 'Humidity',
                    content: flowerInfo['humidity'],
                    icon: Icons.water,
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
                                'Take a photo every week to track your plant\'s growth and health over time!',
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
        backgroundColor: flowerInfo['color'],
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