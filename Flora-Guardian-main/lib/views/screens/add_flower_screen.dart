import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora_guardian/controllers/flower_controller.dart';
import 'package:flora_guardian/models/flower_model.dart';
import 'package:flora_guardian/views/custom_widgets/online_flowers_list.dart';
import 'package:flora_guardian/views/custom_widgets/search_bar_field.dart';
import 'package:flora_guardian/views/screens/flower_info_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:random_string/random_string.dart';
import 'package:flora_guardian/services/cache_service.dart';
// import 'package:logger/logger.dart';
class AddFlowerScreen extends StatefulWidget {
  const AddFlowerScreen({super.key});

  @override
  State<AddFlowerScreen> createState() => _AddFlowerScreenState();
}

class _AddFlowerScreenState extends State<AddFlowerScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlowerController _flowerController = FlowerController();
  final CacheService _cacheService = CacheService();
  List<FlowerModel> flowers = [];
  final uid = FirebaseAuth.instance.currentUser!.uid.toString();
  static const int _pageSize = 20;
  bool _hasReachedMax = false;

  bool isLoading = true;
  bool isLoadingMore = false;
  String searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final cachedFlowers = _cacheService.getCachedFlowers(searchQuery);
    if (cachedFlowers != null) {
      setState(() {
        flowers = cachedFlowers;
        isLoading = false;
      });
    } else {
      await _loadFlowers();
    }
    _scrollController.addListener(_optimizedScrollListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.removeListener(_optimizedScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _optimizedScrollListener() {
    if (!isLoadingMore &&
        !_hasReachedMax &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500) {
      _loadMoreFlowers();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        flowers.clear();
        _flowerController.reset();
        isLoading = true;
      });
      _loadFlowers();
    });
  }

  Future<void> _loadFlowers() async {
    try {
      final fetchedFlowers = await _flowerController.fetchFlowers(
        query: searchQuery,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          flowers = fetchedFlowers;
          isLoading = false;
          _hasReachedMax = fetchedFlowers.isEmpty;
        });
        _cacheService.cacheFlowers(searchQuery, fetchedFlowers);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreFlowers() async {
    if (isLoadingMore || _hasReachedMax) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final newFlowers = await _flowerController.fetchFlowers(
        query: searchQuery,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (newFlowers.isEmpty) {
            _hasReachedMax = true;
          } else {
            flowers.addAll(newFlowers);
            _cacheService.cacheFlowers(searchQuery, flowers);
          }
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildFlowerItem(FlowerModel flower) {
    final String imageUrl =
        flower.defaultImage?.thumbnail ??
        flower.defaultImage?.smallUrl ??
        'https://via.placeholder.com/150?text=No+Image';

    return OnlineFlowersList(
      flowerImage: imageUrl,
      commonName: flower.commonName.isNotEmpty ? flower.commonName : 'Unknown',
      scientificName:
          flower.scientificName.isNotEmpty
              ? flower.scientificName[0]
              : 'Unknown',
      onListTap: () => _navigateToFlowerInfo(flower),
      onAddTap: () => _addFlowerToProfile(flower),
    );
  }

  void _navigateToFlowerInfo(FlowerModel flower) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FlowerInfoScreen(
              image:
                  flower.defaultImage?.mediumUrl ??
                  flower.defaultImage?.regularUrl ??
                  flower.defaultImage?.smallUrl ??
                  'https://via.placeholder.com/150?text=No+Image',
              flowerName: flower.commonName,
              sunlight:
                  flower.sunlight.isNotEmpty ? flower.sunlight[0] : 'Unknown',
              wateringCycle: flower.watering,
              scientifcName:
                  flower.scientificName.isNotEmpty
                      ? flower.scientificName[0]
                      : 'Unknown',
              cycle: flower.cycle,
            ),
      ),
    );
  }
Future<void> _addFlowerToProfile(FlowerModel flower) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    _showSnackBar('You must be logged in to add a flower');
    return;
  }

  // Show a loading dialog
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
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Adding flower..."),
            ],
          ),
        ),
      );
    },
  );

  try {
    String id = randomAlphaNumeric(6);
    bool success = await _flowerController.saveFlowerToDb(id, flower, uid);

    // Close the loading dialog
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (success) {
      _showSnackBar('Flower added to profile');
      // Refresh the list of flowers
      setState(() {
        // Optionally, you can refresh the list or update the state as needed
      });
    } else {
      _showSnackBar('This flower is already in your profile');
    }
  } catch (e) {
    // Close the loading dialog if there's an error
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _showSnackBar('Error adding flower: ${e.toString()}');
  }
}

  void _showSnackBar(String message) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 200, // Adjusted margin
        left: 20,
        right: 20,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add new flowers 🌻",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.face, color: Colors.black, size: 40),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: SearchBarField(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search 'Rose'",
              controller: searchController,
              onChanged: _onSearchChanged,
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: flowers.length + (_hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index == flowers.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child:
                                isLoadingMore
                                    ? CircularProgressIndicator()
                                    : SizedBox.shrink(),
                          ),
                        );
                      }
                      return _buildFlowerItem(flowers[index]);
                    },
                    addAutomaticKeepAlives: true,
                    cacheExtent: 100,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}