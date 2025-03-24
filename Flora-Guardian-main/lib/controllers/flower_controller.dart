import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flora_guardian/models/flower_model.dart';

class FlowerController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isFlowerExists(String flowerId, String userUid) async {
    try {
      final QuerySnapshot querySnapshot = await _db
          .collection('user_flowers')
          .where('userId', isEqualTo: userUid)
          .where('id', isEqualTo: flowerId)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking flower existence: $e');
    }
  }

  Future<bool> saveFlowerToDb(FlowerModel flower, String userUid) async {
    try {
      bool exists = await isFlowerExists(flower.id, userUid);
      if (exists) {
        return false; // Flower already exists
      }
      Map<String, dynamic> flowerData = flower.toJson();
      flowerData['userId'] = userUid;
      await _db.collection('user_flowers').doc(flower.id).set(flowerData);
      return true;
    } catch (e) {
      throw Exception('Failed to save flower: $e');
    }
  }

  Stream<List<FlowerModel>> loadFlowersFromFirebase(String userUid) {
    return _db
        .collection('user_flowers')
        .where('userId', isEqualTo: userUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlowerModel.fromJson(doc.data()))
            .toList());
  }

  // New Method: Delete Flower
  Future<void> deleteFlower(String userUid, int flowerId) async {
    try {
      // Check if the flower exists before attempting to delete
      bool exists = await isFlowerExists(flowerId.toString(), userUid);
      if (!exists) {
        throw Exception('Flower does not exist');
      }

      // Delete the flower document from Firestore
      await _db
          .collection('user_flowers')
          .doc(flowerId.toString()) // Assuming `flowerId` is used as the document ID
          .delete();

      ('Flower deleted successfully');
    } catch (e) {
      throw Exception('Failed to delete flower: $e');
    }
  }
}