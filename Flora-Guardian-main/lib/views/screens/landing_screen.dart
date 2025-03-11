import 'package:flutter/material.dart';
import 'package:flora_guardian/views/custom_widgets/custom_button.dart';
import 'package:flora_guardian/views/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade100,
                ],
              ),
            ),
          ),
          
          // Decorative plant illustrations at the bottom
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     "assets/images/plants_footer.png", // You'll need to add this asset
          //     fit: BoxFit.fitWidth,
          //   ),
          // ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.08),
                    
                    // App logo or icon
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_florist,
                          size: 60,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // App name
                    Text(
                      "Flora Guardian",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Tagline
                    Text(
                      "Your Personal Plant Care Companion",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    SizedBox(height: 50),
                    
                    // App features section
                    FeatureItem(
                      icon: Icons.water_drop_outlined,
                      title: "Watering Reminders",
                      description: "Never forget to water your plants with personalized reminders",
                    ),
                    
                    SizedBox(height: 30),
                    
                    FeatureItem(
                      icon: Icons.wb_sunny_outlined,
                      title: "Light Monitoring",
                      description: "Track optimal light conditions for your plant collection",
                    ),
                    
                    SizedBox(height: 30),
                    
                    FeatureItem(
                      icon: Icons.scanner_outlined,
                      title: "Plant Identification",
                      description: "Identify plants and get care instructions with a simple scan",
                    ),
                    
                    SizedBox(height: 60),
                    
                    // Get Started button
                    CustomButton(
                      backgroundColor: Colors.green.shade700,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      text: "Get Started",
                      textColor: Colors.white,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Login text
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Already have an account? Log in",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Feature item widget
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 30,
            color: Colors.green.shade700,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}