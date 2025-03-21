import 'package:flora_guardian/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flora_guardian/controllers/flower_controller.dart';
import 'package:flora_guardian/models/flower_model.dart';
import 'package:flora_guardian/views/screens/add_flower_screen.dart';
import 'package:flora_guardian/views/screens/flower_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlowerController _flowerController = FlowerController();
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  // Search functionality
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query.toLowerCase();
      });
    });
  }

  Future<void> _deleteFlower(int flowerId) async {
    try {
      await _flowerController.deleteFlower(userUid, flowerId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plant deleted successfully'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete plant: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _confirmDelete(FlowerModel flower) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Plant",
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete '${flower.commonName}'? This action cannot be undone.",
            style: TextStyle(color: Colors.grey.shade700),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
           TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteFlower(int.parse(flower.id)); // Convert String to int
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.green.shade50,
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddFlowerScreen()),
          );
        },
      ),
      appBar: AppBar(
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
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(Icons.person_outline, color: Colors.green.shade700, size: 22),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade400),
                    const SizedBox(width: 10),
                    const Text("Logout"),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 0) {
                // Handle logout logic here
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                      hintText: "Search 'Rose'",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              // Subtitle
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Your Plants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Flowers grid
              Expanded(
                child: StreamBuilder<List<FlowerModel>>(
                  stream: _flowerController.loadFlowersFromFirebase(userUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.green.shade700),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              size: 70,
                              color: Colors.green.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your garden is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Add your first plant by tapping the + button',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final flowers = snapshot.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: flowers.length,
                      itemBuilder: (context, index) {
                        final flower = flowers[index];
                        if (searchQuery.isNotEmpty &&
                            !flower.commonName.toLowerCase().contains(searchQuery)) {
                          return const SizedBox.shrink();
                        }

                        return Stack(
                          children: [
                            // Main card
                            GestureDetector(
                              onTap: () {
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
                              },
                              child: Container(
                                height: 160,
                                width: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
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

                            // Delete button
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _confirmDelete(flower),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
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
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}