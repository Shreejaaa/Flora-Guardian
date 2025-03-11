import 'package:flutter/material.dart';

class SearchBarField extends StatelessWidget {
  final Widget? prefixIcon;
  final String hintText;
  final TextEditingController controller;
  final Function(String)? onChanged;

  const SearchBarField({
    super.key,
    this.prefixIcon,
    required this.hintText,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
