import 'package:flutter/material.dart';
import 'package:flora_guardian/views/custom_widgets/custom_button.dart';
import 'package:flora_guardian/controllers/user_controller.dart';
import 'package:flora_guardian/models/user_model.dart';
import 'package:flora_guardian/services/profile_cache_service.dart';
import 'package:flora_guardian/views/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = UserController();
  final ProfileCacheService _profileCache = ProfileCacheService();
  late Future<UserModel?> _userDataFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadInitialData();
  }

  Future<UserModel?> _loadInitialData() async {
    try {
      if (_userController.getCurrentUser().isEmpty) return null;

      // Try to get cached data first
      final cachedUser = _profileCache.getCachedUser();
      if (cachedUser != null) {
        _refreshUserDataInBackground();
        return cachedUser;
      }

      // If no cached data, load fresh data
      return await _userController.getUserData();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      return null;
    }
  }

  Future<void> _refreshUserDataInBackground() async {
    try {
      final freshData = await _userController.getUserData();
      if (freshData != null) {
        _profileCache.cacheUser(freshData);
        if (mounted) {
          setState(() => _userDataFuture = Future.value(freshData));
        }
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  Future<void> _refreshProfile() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final userData = await _userController.getUserData();
      if (userData != null) {
        _profileCache.cacheUser(userData);
        if (mounted) {
          setState(() => _userDataFuture = Future.value(userData));
        }
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileContent(UserModel? userData) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header (Centralized)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.green.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative Circle Background
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade100,
                        ),
                      ),
                      // Avatar
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData?.userName ?? "Not available",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?.email ?? "Not available",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProfileItem(Icons.person, "Username", userData?.userName),
                          const Divider(height: 20),
                          _buildProfileItem(Icons.email, "Email", userData?.email),
                          const Divider(height: 20),
                          _buildProfileItem(Icons.lock, "Password", "********"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    backgroundColor: Colors.green.shade700,
                    onPressed: () => _navigateToEditProfile(userData),
                    text: "Edit Profile",
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700, size: 24),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        value ?? "Not available",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _navigateToEditProfile(UserModel? userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: userData),
      ),
    ).then((_) {
      _profileCache.clearCache();
      setState(() {
        _userDataFuture = _loadInitialData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.green.shade50,
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
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
              ),
            )
          else
            IconButton(
              onPressed: _refreshProfile,
              icon: Icon(Icons.refresh, color: Colors.green.shade800),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.green.shade700),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 70,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please login to view profile',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildProfileContent(snapshot.data);
          },
        ),
      ),
    );
  }
}