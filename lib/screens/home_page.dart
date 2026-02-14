import 'package:flutter/material.dart';
import 'package:quiz_app1/base/pages/courses_page.dart';
import 'package:quiz_app1/base/pages/fiszki_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
         child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi 👋',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ready to learn?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C28),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.star, color: Colors.amber),
                  )
                ],
              ),

              const SizedBox(height: 24),

              // ===== SEARCH =====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C28),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.white54),
                    SizedBox(width: 10),
                    Text(
                      'Search...',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
// ===== PRZYCISK FISZKI =====
InkWell(
  borderRadius: BorderRadius.circular(20),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FiszkiPage(),
      ),
    );
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6A5AE0),
          Color(0xFF4D4AE8),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(
          Icons.menu_book_rounded,
          color: Colors.white,
          size: 32,
        ),
        SizedBox(height: 12),
        Text(
          'FISZKI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Ucz się szybko i skutecznie',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 24),
              // ===== KURSY (sekcja z trzema kafelkami) =====
              const Text(
                'KURSY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // trzy kafelki w wierszu (responsywne)
              Column(
                children: [
                  const SizedBox(height: 12),
                  _CourseTile(
                    title: 'Biologia',
                    subtitle: 'Anatomia, Ekologia',
                    icon: Icons.eco,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7BE495), Color(0xFF00C853)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursePage(title: 'Biologia')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _CourseTile(
                    title: 'Chemia',
                    subtitle: 'Organiczna, Nieorganiczna',
                    icon: Icons.science,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A8B), Color(0xFFFBCB0A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursePage(title: 'Chemia')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _CourseTile(
                    title: 'Matematyka',
                    subtitle: 'Algebra, Geometria',
                    icon: Icons.calculate,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CA1FF), Color(0xFF0072FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      // przykładowa nawigacja - możesz podłączyć inny ekran
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursePage(title: 'Matematyka')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              
            ],
          ),
        ),
      ),
    );
  }
}

/// Mały komponent kafelka kursu
class _CourseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _CourseTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // responsywna szerokość - trzy kafelki mieszczą się w jednym wierszu

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
       width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 2, offset: const Offset(-2, -2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ikona w kółku
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            // mały "start" badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('START', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
