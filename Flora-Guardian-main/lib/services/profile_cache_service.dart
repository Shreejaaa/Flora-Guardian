import 'package:flora_guardian/models/user_model.dart';

class ProfileCacheService {
  static final ProfileCacheService _instance = ProfileCacheService._internal();
  factory ProfileCacheService() => _instance;
  ProfileCacheService._internal();

  UserModel? _cachedUser;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  bool get hasCachedUser => _cachedUser != null;

  void cacheUser(UserModel user) {
    _cachedUser = user;
    _lastFetchTime = DateTime.now();
  }

  UserModel? getCachedUser() {
    if (_cachedUser == null) return null;

    if (_lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _cacheExpiry) {
      return _cachedUser; // Return cached data even if expired, will refresh in background
    }

    return _cachedUser;
  }

  void clearCache() {
    _cachedUser = null;
    _lastFetchTime = null;
  }
}
