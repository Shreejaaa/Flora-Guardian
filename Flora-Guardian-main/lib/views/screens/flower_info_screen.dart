// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class FlowerInfoScreen extends StatelessWidget {
  final String image;
  final String flowerName;
  final String sunlight;
  final String wateringCycle;
  final String cycle;
  final String scientifcName;

  const FlowerInfoScreen({
    super.key,
    required this.image,
    required this.flowerName,
    required this.sunlight,
    required this.wateringCycle,
    required this.cycle,
    required this.scientifcName,
  });

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        // title: Text("Flower Details", 
        //   style: TextStyle(
        //     color: Colors.white, 
        //     fontWeight: FontWeight.bold,
        //     shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))]
        //   )
        // ),
      ),
      body: Stack(
        children: [
          // Hero image with gradient overlay
          Container(
            height: mq.height * 0.45,
            width: mq.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          
          // Content area
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: mq.height * 0.35),
                
                // Info container
                Container(
                  width: mq.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Flower name with decorative line
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 5,
                              decoration: BoxDecoration(
                                // color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                flowerName,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 6),
                        // Scientific name in italics
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(
                            scientifcName,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 30),
                        
                        // Info cards
                        _buildInfoCard(
                          context: context,
                          title: "Watering Cycle",
                          content: wateringCycle,
                          icon: Icons.water_drop,
                          color: Colors.blue.shade100,
                          iconColor: Colors.blue.shade700,
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildInfoCard(
                          context: context,
                          title: "Sunlight",
                          content: sunlight,
                          icon: Icons.wb_sunny,
                          color: Colors.amber.shade100,
                          iconColor: Colors.amber.shade700,
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildInfoCard(
                          context: context,
                          title: "Cycle",
                          content: cycle,
                          icon: Icons.repeat,
                          color: Colors.green.shade100,
                          iconColor: Colors.green.shade700,
                        ),
                        
                        SizedBox(height: 30),
                        
                        // Care tips section
                        Text(
                          "Care Tips",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildCareTip(
                          tip: "Place your ${flowerName.toLowerCase()} in a location with adequate ${sunlight.toLowerCase()} as recommended.",
                          icon: Icons.lightbulb_outline,
                        ),
                        
                        _buildCareTip(
                          tip: "Water according to the ${wateringCycle.toLowerCase()} cycle for optimal growth.",
                          icon: Icons.check_circle_outline,
                        ),
                        
                        _buildCareTip(
                          tip: "This plant follows a ${cycle.toLowerCase()} growing pattern.",
                          icon: Icons.eco_outlined,
                        ),
                        
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTip({required String tip, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.green.shade600,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}