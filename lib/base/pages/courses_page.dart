import 'package:flutter/material.dart';

class CoursePage extends StatelessWidget {
  final String title;

  const CoursePage({
    super.key,
    required this.title,
  });

  // helper: wybiera gradient i ikonę na podstawie tytułu kursu
  Map<String, dynamic> _themeFor(String title) {
    final key = title.toLowerCase();
    if (key.contains('bio') || key.contains('biologia')) {
      return {
        'icon': Icons.eco,
        'gradient': const LinearGradient(
          colors: [Color(0xFF7BE495), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    } else if (key.contains('chem')) {
      return {
        'icon': Icons.science,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF9A8B), Color(0xFFFBCB0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    } else if (key.contains('math') || key.contains('matem')) {
      return {
        'icon': Icons.calculate,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4CA1FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    } else {
      return {
        'icon': Icons.menu_book_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF4D4AE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    }
  }

  // ============ Znaczek na górze ============
  Widget buildCourseHeader({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ============ Pasek Wyszukiwania ============
  Widget buildQuizSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C28),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white54),
            SizedBox(width: 10),
            Text(
              'Szukaj quizu...',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(title);
    final IconData icon = theme['icon'] as IconData;
    final LinearGradient gradient = theme['gradient'] as LinearGradient;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      // pozostawiam AppBar (możesz go schować jeśli chcesz używać headera jako nagłówka)
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCourseHeader(title: title, icon: icon, gradient: gradient),
              buildQuizSearchBar(),
              // placeholder — tu w przyszłości lista quizów/lekcji
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    Text(
                      'Dostępne quizy',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    // tymczasowy placeholder
                    Text(
                      'Tutaj pojawi się lista quizów dla wybranego kursu. Wyszukiwarka powyżej będzie filtrować tę listę.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
