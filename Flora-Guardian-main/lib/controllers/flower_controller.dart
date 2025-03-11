import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flora_guardian/models/flower_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlowerController {
  final _db = FirebaseFirestore.instance;

  int _currentPage = 1;
  bool _hasMore = true;

  // load flowers from API
  Future<List<FlowerModel>> fetchFlowers({
    String? query,
    int pageSize = 20,
  }) async {
    if (!_hasMore) return [];

    try {
      String baseUrl =
          'https://perenual.com/api/species-list?key=sk-LOGX67c4032bc67278915&page=$_currentPage';
      if (query != null && query.isNotEmpty) {
        baseUrl = '$baseUrl&q=${Uri.encodeComponent(query)}';
      }

      final url = Uri.parse(baseUrl);
      debugPrint('Fetching URL: $url'); // Add this for debugging

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> flowersData = data['data'];

        // Check if we've reached the last page
        if (flowersData.isEmpty) {
          _hasMore = false;
          return [];
        }

        _currentPage++;
        return flowersData
            .map((flower) => FlowerModel.fromJson(flower))
            .toList();
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load flowers');
      }
    } catch (e) {
      debugPrint('Error fetching flowers: $e');
      throw Exception('Error fetching flowers: $e');
    }
  }

  void reset() {
    _currentPage = 1;
    _hasMore = true;
  }

  bool get hasMore => _hasMore;

 Future<bool> isFlowerExists(int flowerId, String userUid) async {
  try {
    final querySnapshot =
        await _db
          .collection("flowers")
          .where("userId", isEqualTo: userUid)
          .where("id", isEqualTo: flowerId)
          .get();
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    debugPrint("Error checking flower existence: ${e.toString()}");
    throw Exception('Error checking flower existence: $e');
  }
}

Future<bool> saveFlowerToDb(
  String docId,
  FlowerModel flower,
  String userUid,
) async {
  try {
    // Check if flower already exists
    bool exists = await isFlowerExists(flower.id, userUid);
    if (exists) {
      return false;
    }
    
    Map<String, dynamic> flowerData = flower.toJson();
    flowerData['userId'] = userUid;
    
    // Using docId as the document ID
    await _db.collection("flowers").doc(docId).set(flowerData);
    return true;
  } catch (e) {
    debugPrint("Failed to save flower: ${e.toString()}");
    throw Exception('Failed to save flower: $e');
  }
}

  Future<Stream<List<FlowerModel>>> loadFlowersFromFirebase(
    String userUid,
  ) async {
    try {
      return _db
          .collection("flowers")
          .where("userId", isEqualTo: userUid)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => FlowerModel.fromJson(doc.data()))
                    .toList(),
          );
    } catch (e) {
      debugPrint("Error loading flowers: ${e.toString()}");
      throw Exception('Error loading flowers: $e');
    }
  }
}
