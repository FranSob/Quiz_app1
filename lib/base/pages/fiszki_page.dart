import 'package:flutter/material.dart';

class FiszkiPage extends StatelessWidget {
  const FiszkiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        title: const Text('Fiszki'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // standardowa strzałka w lewo
          onPressed: () {
            Navigator.pop(context); // wraca do poprzedniej strony
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Tutaj będą fiszki!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
