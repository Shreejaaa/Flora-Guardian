import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final Icon? suffixIcon;
  final VoidCallback? onPressedSuffix;
  final TextEditingController controller;
  final bool obscureText;
  final Color textColor;
  final TextInputType textInputType;
  const CustomTextfield({
    super.key,
    required this.hintText,
    this.suffixIcon,
    required this.controller,
    this.onPressedSuffix,
    required this.obscureText,
    required this.textInputType,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        keyboardType: textInputType,
        style: TextStyle(color: textColor),
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          suffixIcon:
              suffixIcon != null
                  ? IconButton(onPressed: onPressedSuffix, icon: suffixIcon!)
                  : null,
          hintText: hintText,

          hintStyle: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          filled: true,
          fillColor: const Color.fromARGB(88, 255, 255, 255),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
