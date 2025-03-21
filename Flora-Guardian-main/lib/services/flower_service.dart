import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flora_guardian/models/flower_model.dart';

class FlowerService {
  static Future<List<FlowerModel>> loadFlowersFromJson() async {
    try {
      final String response = await rootBundle.loadString('assets/flowers.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => FlowerModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load flowers: $e');
    }
  }
}