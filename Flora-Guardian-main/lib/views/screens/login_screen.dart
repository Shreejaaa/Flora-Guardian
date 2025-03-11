import 'package:flutter/material.dart';
import 'package:flora_guardian/controllers/user_controller.dart';
import 'package:flora_guardian/views/custom_widgets/custom_button.dart';
import 'package:flora_guardian/views/screens/signup_screen.dart';
import 'package:flora_guardian/views/screens/password_reset_screen.dart';
import 'package:flora_guardian/views/screens/main_screen.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;
  bool isLogin = false;
  String? emailError;
  String? passwordError;
  String? generalError;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final logger = Logger();

  void onPressedSuffix() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      emailError = null;
      passwordError = null;
      generalError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLogin = true;
    });

    try {
      final error = await UserController().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (error != null) {
        if (!mounted) return;
        setState(() {
          if (error.toLowerCase().contains("user not found")) {
            emailError = "User not found. Please check your email.";
          } else if (error.toLowerCase().contains("incorrect password")) {
            passwordError = "Incorrect password. Please try again.";
          } else if (error.toLowerCase().contains("invalid email or password")) {
            generalError = "Invalid email or password. Please check your credentials.";
          } else {
            generalError = error; // Display all other errors
          }
        });
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(),
          ),
        );
      }
    } catch (e) {
      logger.e("Login error: $e");
      setState(() {
        generalError = "An unexpected error occurred. Please try again.";
      });
    } finally {
      setState(() {
        isLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.08),

                    // App logo
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_florist,
                          size: 60,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // App name
                    Text(
                      "Flora Guardian",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "Your Personal Plant Care Companion",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade900,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: 50),

                    // Email field
                    TextFormField(
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        errorText: emailError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Password field
                    TextFormField(
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        errorText: passwordError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PasswordResetScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Login button
                    isLogin
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.green.shade700,
                            ),
                          )
                        : CustomButton(
                            backgroundColor: Colors.green.shade700,
                            onPressed: _handleLogin,
                            text: "Login",
                            textColor: Colors.white,
                          ),

                    SizedBox(height: 20),

                    // Sign up link
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Create one",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 50),
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