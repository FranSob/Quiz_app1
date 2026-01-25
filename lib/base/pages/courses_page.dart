import 'package:flutter/material.dart';

class CoursePage extends StatelessWidget {
  final String title;

  const CoursePage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Kurs: $title',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
