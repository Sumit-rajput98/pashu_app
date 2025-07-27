import 'package:flutter/material.dart';

class MyInvestmentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MyInvestmentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF35C75A), // Button background color
        foregroundColor: Colors.white, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'My Investment',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
