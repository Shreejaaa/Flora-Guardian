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
      appBar: AppBar(title: Text("Flowes Info")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: mq.width,
                  height: mq.height * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(image,fit: BoxFit.cover,),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  flowerName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  height: 100,
                  width: mq.width,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Watering Cycle",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height:6),

                      Text(wateringCycle,style: TextStyle(fontSize: 16),),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  height: 100,
                  width: mq.width,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sunlight",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height:6),

                      Text(sunlight,style: TextStyle(fontSize: 16),)
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  height: 100,
                  width: mq.width,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cycle",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height:6),
                      Text(cycle,style: TextStyle(fontSize: 16),)
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  height: 100,
                  width: mq.width,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scientific Name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height:6),

                      Text(scientifcName,style: TextStyle(fontSize: 16),)
                    ],
                  ),
                ),
                SizedBox(height: 20),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
