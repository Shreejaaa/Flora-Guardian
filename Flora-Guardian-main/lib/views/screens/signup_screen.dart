import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora_guardian/controllers/user_controller.dart';
import 'package:flora_guardian/models/user_model.dart';
import 'package:flora_guardian/views/custom_widgets/custom_button.dart';
// import 'package:flora_guardian/views/custom_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isObscure = true;
  bool isSignup = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  void onPressedSuffix() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient to match landing page
          Container(
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
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.02),
                    
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.green.shade800,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    // App logo or icon (same as landing page)
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1), // Use .withValues()
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_florist,
                          size: 50,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Title - matching font style from landing page
                    Text(
                      "Join Flora Guardian",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Subtitle - matching style from landing page
                    Text(
                      "Create your account to get started",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Input fields with consistent styling
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.green.shade700),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green.shade700),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green.shade700),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: passwordController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility : Icons.visibility_off,
                            color: Colors.green.shade700,
                          ),
                          onPressed: onPressedSuffix,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green.shade700),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Sign up button - matching the style from landing page
                    isSignup
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.green.shade700,
                          ),
                        )
                      : CustomButton(
                          backgroundColor: Colors.green.shade700,
                          onPressed: () async {
                            // Validate inputs
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                usernameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All fields are required'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(emailController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid email'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            // Show loading indicator
                            setState(() {
                              isSignup = true;
                            });
                            User? user = await UserController().signup(
                              emailController.text,
                              passwordController.text,
                            );
                            if (user != null) {
                              UserModel userModel = UserModel(
                                uid: user.uid,
                                userName: usernameController.text,
                                email: emailController.text,
                              );
                              await UserController().saveUseToDb(userModel);
                              
                              if (!mounted) return;
                              
                              // Show success animation before popping
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text('Account created successfully!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pop(context);
                              });
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to create account'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                isSignup = false;
                              });
                            }
                          },
                          text: "Create Account",
                          textColor: Colors.white,
                        ),
                    
                    SizedBox(height: 20),
                    
                    // Login link - matching style from landing page
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Already have an account? Log in",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Plant fact section (simplified from the original)
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Plants communicate with each other through underground fungal networks.",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.08),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}