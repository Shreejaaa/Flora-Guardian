import 'package:flutter/material.dart';
import 'package:flora_guardian/controllers/user_controller.dart';
import 'package:flora_guardian/models/user_model.dart';
import 'package:flora_guardian/views/custom_widgets/custom_button.dart';
import 'package:flora_guardian/views/custom_widgets/edit_profile_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = UserController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if user data exists
    _usernameController.text = widget.user?.userName ?? '';
    _emailController.text = widget.user?.email ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModel(
        uid: widget.user?.uid ?? _userController.getCurrentUser(),
        userName: _usernameController.text,
        email: _emailController.text,
        modifiedDate: DateTime.now(),
      );

      final success = await _userController.updateUser(updatedUser);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    centerTitle: false,
                    toolbarHeight: 80,
                    title: Row(
                      children: [
                        Icon(Icons.local_florist, color: Colors.green.shade800, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "Flora Guardian",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.green.shade800),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Main Content
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Your Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Edit your details below',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username Field
                        EditProfileTextField(
                          initialValue: widget.user?.userName ?? '',
                          controller: _usernameController,
                          prefixIcon: Icons.person_outline,
                          labelText: 'Username',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        EditProfileTextField(
                          initialValue: widget.user?.email ?? '',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          labelText: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        CustomButton(
                          backgroundColor: Colors.green.shade700,
                          onPressed: _updateProfile,
                          text: 'Save Changes',
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Divider(
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),

                        // Additional Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.green.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'All fields are required',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}