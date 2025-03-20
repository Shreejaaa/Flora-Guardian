import 'package:flutter/material.dart';

class EditProfileTextField extends StatelessWidget {
  final String initialValue;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const EditProfileTextField({
    super.key,
    required this.initialValue,
    this.obscureText = false,
    required this.controller,
    this.validator, required IconData prefixIcon, required String labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller..text = initialValue,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: validator,
      ),
    );
  }
}
