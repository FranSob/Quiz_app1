import 'package:flutter/material.dart';
import 'package:quiz_app1/base/widgets/fiszki.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              const Text(
                'HOME PAGE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              InkWell(
  borderRadius: BorderRadius.circular(20),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardApp(),
      ),
    );
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: Colors.deepPurple,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Center(
      child: Text(
        '+ FISZKI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
),


              const SizedBox(height: 32),

              // ===== KURSY / QUIZY =====
              const Text(
                'KURSY / QUIZY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ===== BIOLOGIA + CHEMIA (GRID) =====
              Row(
                children: [
                  Expanded(
                    child: _CourseCard(
                      title: 'Biologia',
                      icon: Icons.biotech,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CourseCard(
                      title: 'Chemia',
                      icon: Icons.science,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ===== MATEMATYKA (FULL WIDTH) =====
              _CourseCard(
                title: 'Matematyka',
                icon: Icons.calculate,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool fullWidth;

  const _CourseCard({
    required this.title,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullWidth ? 100 : 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
