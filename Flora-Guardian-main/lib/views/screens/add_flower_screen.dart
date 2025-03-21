import 'package:flutter/material.dart';
import 'package:flora_guardian/models/flower_model.dart';
import 'package:flora_guardian/services/flower_service.dart';
import 'package:flora_guardian/controllers/flower_controller.dart';
import 'package:flora_guardian/views/screens/flower_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFlowerScreen extends StatefulWidget {
  const AddFlowerScreen({super.key});

  @override
  State<AddFlowerScreen> createState() => _AddFlowerScreenState();
}

class _AddFlowerScreenState extends State<AddFlowerScreen> {
  final FlowerController _flowerController = FlowerController();
  List<FlowerModel> flowers = [];
  List<FlowerModel> filteredFlowers = [];
  bool isLoading = true;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFlowers();
  }

  Future<void> _loadFlowers() async {
    try {
      final fetchedFlowers = await FlowerService.loadFlowersFromJson();
      setState(() {
        flowers = fetchedFlowers;
        filteredFlowers = fetchedFlowers; // Initialize filtered list
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load flowers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Search functionality
  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFlowers = flowers; // Reset to full list
      } else {
        filteredFlowers = flowers
            .where((flower) =>
                flower.commonName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateToFlowerInfo(FlowerModel flower) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlowerInfoScreen(
          image: flower.picture,
          flowerName: flower.commonName,
          sunlight: flower.lighting,
          wateringCycle: flower.wateringCycle,
          scientifcName: flower.scientificName.join(', '),
          humidity: flower.humidity,
        ),
      ),
    );
  }

  Future<void> _addFlowerToProfile(FlowerModel flower) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to add a flower'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green.shade700),
                const SizedBox(width: 20),
                Text("Adding flower...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );

    try {
      bool success = await _flowerController.saveFlowerToDb(flower, uid);
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flower added to profile'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This flower is already in your profile'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding flower: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade100,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // App Bar
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: false,
              toolbarHeight: 80,
              title: Row(
                children: [
                  Icon(Icons.local_florist, color: Colors.green.shade800, size: 32),
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
                  icon: Icon(Icons.face, color: Colors.green.shade800, size: 32),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
              ],
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                  hintText: "Search 'Rose'",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // Flower List
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.green.shade700))
                  : filteredFlowers.isEmpty
                      ? _emptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: filteredFlowers.length,
                          itemBuilder: (context, index) {
                            final flower = filteredFlowers[index];
                            return _buildFlowerItem(flower);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowerItem(FlowerModel flower) {
    return Stack(
      children: [
        // Main card
        GestureDetector(
          onTap: () => _navigateToFlowerInfo(flower),
          child: Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10), // Rounded corners for square shape
              image: DecorationImage(
                image: NetworkImage(flower.picture),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
            child: flower.picture.isEmpty
                ? Center(
                    child: Icon(
                      Icons.local_florist_outlined,
                      size: 40,
                      color: Colors.green.shade300,
                    ),
                  )
                : null,
          ),
        ),

        // Add button
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => _addFlowerToProfile(flower),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                size: 24,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_flowers.png', // Replace with your own illustration
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'No flowers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different flower',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}