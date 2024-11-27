import 'package:flutter/material.dart';

class Tentang extends StatelessWidget {
  const Tentang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/about.jpg', // Path to your image asset
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Add more widgets here if needed, such as text or buttons
        ],
      ),
    );
  }
}
