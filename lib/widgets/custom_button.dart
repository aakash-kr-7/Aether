import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[700],
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(text, style: TextStyle(fontSize: 16)),
    );
  }
}
