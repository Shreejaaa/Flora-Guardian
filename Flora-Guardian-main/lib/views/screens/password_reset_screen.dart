import 'package:flora_guardian/controllers/user_controller.dart';
import 'package:flora_guardian/views/custom_widgets/custom_button.dart';
import 'package:flora_guardian/views/custom_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController emailController = TextEditingController();

  void _resetPassword() async {
    if (emailController.text.isEmpty) return;

    bool success = await UserController().resetPassword(emailController.text);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Password reset email sent! Check your inbox.'
              : 'Failed to send reset email. Please try again.',
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email to reset password',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            CustomTextfield(
              textColor: Colors.black,
              hintText: "Email",
              controller: emailController,
              obscureText: false,
              textInputType: TextInputType.emailAddress,
              suffixIcon: Icon(Icons.email_outlined),
            ),
            SizedBox(height: 20),
            CustomButton(
              backgroundColor: Colors.black,
              onPressed: _resetPassword,
              text: "Send Reset Link",
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
