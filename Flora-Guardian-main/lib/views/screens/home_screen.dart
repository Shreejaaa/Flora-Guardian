import 'package:flora_guardian/controllers/user_controller.dart';
import 'package:flora_guardian/views/custom_widgets/flowers_list.dart';
import 'package:flora_guardian/views/custom_widgets/search_bar_field.dart';
import 'package:flora_guardian/views/screens/add_flower_screen.dart';
import 'package:flora_guardian/views/screens/flower_info_screen.dart';
import 'package:flora_guardian/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora_guardian/controllers/flower_controller.dart';
import 'package:flora_guardian/models/flower_model.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final FlowerController _flowerController = FlowerController();
  final String userUid = FirebaseAuth.instance.currentUser!.uid;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddFlowerScreen()),
          );
        },
        label: Text(
          "Add a flower +",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      appBar: AppBar(
        title: const Text("Flora Guardian 🌻"),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.face, color: Colors.black, size: 40),
            itemBuilder:
                (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ],
                    onSelected: (value) async {
                    if (value == 0) {
                      await UserController().logOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      }
                    }
                },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: SearchBarField(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search 'Rose'",
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: BoxDecoration(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Your Flowers",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<Stream<List<FlowerModel>>>(
                      future: _flowerController.loadFlowersFromFirebase(
                        userUid,
                      ),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${asyncSnapshot.error}'),
                          );
                        }

                        if (!asyncSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return StreamBuilder<List<FlowerModel>>(
                          stream: asyncSnapshot.data,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final flowers = snapshot.data ?? [];

                            if (flowers.isEmpty) {
                              return const Center(
                                child: Text('No flowers added yet'),
                              );
                            }

                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: flowers.length,
                              itemBuilder: (context, index) {
                                final flower = flowers[index];
                                // Filter flowers based on search query
                                if (searchQuery.isNotEmpty &&
                                    !flower.commonName.toLowerCase().contains(
                                      searchQuery,
                                    ) &&
                                    !flower.scientificName
                                        .join(' ')
                                        .toLowerCase()
                                        .contains(searchQuery)) {
                                  return const SizedBox.shrink();
                                }
                                return FlowersList(
                                  commonName: flower.commonName,
                                  flowerImage:
                                      flower.defaultImage?.mediumUrl ?? '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => FlowerInfoScreen(
                                              image:
                                                  flower
                                                      .defaultImage
                                                      ?.mediumUrl ??
                                                  flower
                                                      .defaultImage
                                                      ?.regularUrl ??
                                                  flower
                                                      .defaultImage
                                                      ?.smallUrl ??
                                                  'https://via.placeholder.com/150?text=No+Image',
                                              flowerName: flower.commonName,
                                              sunlight:
                                                  flower.sunlight.isNotEmpty
                                                      ? flower.sunlight[0]
                                                      : 'Unknown',
                                              wateringCycle: flower.watering,
                                              scientifcName:
                                                  flower
                                                          .scientificName
                                                          .isNotEmpty
                                                      ? flower.scientificName[0]
                                                      : 'Unknown',
                                              cycle: flower.cycle,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
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
        ],
      ),
    );
  }
}