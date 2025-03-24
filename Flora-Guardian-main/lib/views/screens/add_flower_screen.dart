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
      backgroundColor: Colors.green.shade50,
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
            children: [
              // App Bar matching HomeScreen style with just a back arrow
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    // Back Button (just arrow, no box)
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.green.shade800, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    
                    // Logo and Title
                    Icon(
                      Icons.local_florist,
                      color: Colors.green.shade800,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Flora Guardian",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const Spacer(),
                    
                    // User Icon (using CircleAvatar as in HomeScreen)
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(Icons.person_outline, color: Colors.green.shade700, size: 22),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // Search Bar
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
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                      hintText: "Search for flowers...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              
              // Title
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
                      "Discover Plants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${filteredFlowers.length} plants",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Flower List
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.green.shade700))
                    : filteredFlowers.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: filteredFlowers.length,
                            itemBuilder: (context, index) {
                              final flower = filteredFlowers[index];
                              return _buildFlowerListItem(flower);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowerListItem(FlowerModel flower) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToFlowerInfo(flower),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Flower Image
                Hero(
                  tag: 'flower_${flower.commonName}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: flower.picture.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(flower.picture),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            )
                          : null,
                      color: Colors.green.shade50,
                    ),
                    child: flower.picture.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.local_florist_outlined,
                              size: 30,
                              color: Colors.green.shade300,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Flower Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flower.commonName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flower.scientificName.join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Care indicators - icons only, no text
                      Row(
                        children: [
                          Icon(Icons.water_drop_outlined, size: 16, color: Colors.blue.shade300),
                          const SizedBox(width: 12),
                          Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.amber.shade400),
                          const SizedBox(width: 12),
                          Icon(Icons.water_outlined, size: 16, color: Colors.teal.shade300),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Add Button
                GestureDetector(
                  onTap: () => _addFlowerToProfile(flower),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.green.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No flowers found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different name',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Show all plants'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}