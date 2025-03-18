import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class DiseaseResultPage extends StatefulWidget {
  final String imagePath;

  const DiseaseResultPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<DiseaseResultPage> createState() => _DiseaseResultPageState();
}

class _DiseaseResultPageState extends State<DiseaseResultPage> {
  bool _isLoading = true;
  String _diseaseName = '';
  String _diseaseInfo = '';
  String _treatments = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _detectDisease();
  }

  Future<void> _detectDisease() async {
    try {
      // Prepare the image file for API request
      final File imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Plant.id API endpoint
      final url = Uri.parse('https://api.plant.id/v2/health_assessment');
      
      // API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': 'g4my2D7sWi6Jwk9T9753KHkRiD8P2IY44RnxTquFf2kdv86dK0', 
        },
        body: jsonEncode({
          'images': [base64Image],
          'modifiers': ['crops_fast', 'similar_images'],
          'language': 'en',
          'disease_details': ['description', 'treatment'],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['health_assessment'] != null && 
            data['health_assessment']['diseases'] != null && 
            data['health_assessment']['diseases'].isNotEmpty) {
          
          final disease = data['health_assessment']['diseases'][0];
          
          setState(() {
            _diseaseName = disease['name'] ?? 'Unknown disease';
            _diseaseInfo = disease['description'] ?? 'No information available';
            
            // Extract treatment information
            if (disease['treatment'] != null) {
              final treatment = disease['treatment'];
              _treatments = treatment['chemical'] != null && treatment['biological'] != null
                  ? '${treatment['chemical']}\n\nBiological control: ${treatment['biological']}'
                  : treatment['chemical'] ?? treatment['biological'] ?? 'No treatment information available';
            } else {
              _treatments = 'No treatment information available';
            }
            
            _isLoading = false;
          });
        } else {
          _handleError('No diseases detected in the image.');
        }
      } else {
        _handleError('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Error processing image: $e');
    }
  }
  
  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing plant disease...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildResultView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.black87,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.imagePath),
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          
          // Disease Name
          _buildSection(
            title: 'Detected Disease',
            content: _diseaseName,
            icon: Icons.bug_report,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          
          // Disease Information
          _buildSection(
            title: 'Disease Information',
            content: _diseaseInfo,
            icon: Icons.info_outline,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 16),
          
          // Treatments
          _buildSection(
            title: 'Recommended Treatments',
            content: _treatments,
            icon: Icons.healing,
            color: Colors.green.shade400,
          ),
          
          const SizedBox(height: 32),
          
          // Additional Help Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
            
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This feature will connect you with plant experts')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.green.shade500,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.support_agent),
              label: const Text('Get Expert Help'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}