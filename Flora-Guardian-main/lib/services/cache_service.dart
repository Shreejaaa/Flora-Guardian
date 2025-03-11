import 'package:flora_guardian/models/flower_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, List<FlowerModel>> _flowerCache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  static const Duration _cacheExpiry = Duration(minutes: 15);

  void cacheFlowers(String query, List<FlowerModel> flowers) {
    _flowerCache[query] = flowers;
    _cacheTimestamp[query] = DateTime.now();
  }

  List<FlowerModel>? getCachedFlowers(String query) {
    final timestamp = _cacheTimestamp[query];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      _flowerCache.remove(query);
      _cacheTimestamp.remove(query);
      return null;
    }

    return _flowerCache[query];
  }

  void clearCache() {
    _flowerCache.clear();
    _cacheTimestamp.clear();
  }
}
