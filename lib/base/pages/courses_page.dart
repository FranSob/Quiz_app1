import 'package:flutter/material.dart';
import 'package:quiz_app1/base/pages/interactive_quiz_page.dart'; // <-- podłączenie quizu

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

  // lista tematów (tylko nazwy) dla Biologii — bez fiszek
  List<String> _bioTopics() {
    return [
      'Komórki',
      'Genetyka',
      'Ekologia',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(title);
    final IconData icon = theme['icon'] as IconData;
    final LinearGradient gradient = theme['gradient'] as LinearGradient;

    // jeśli to biologia — przygotuj tematy (lista stringów)
    final bool isBiology = title.toLowerCase().contains('bio');
    final bioTopics = isBiology ? _bioTopics() : <String>[];

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
              // lista tematów / quizów
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Dostępne quizy',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (isBiology)
                      // pokaż boxy tematów dla biologii (tylko nazwy, bez fiszek)
                      ...bioTopics.map((topic) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TopicTile(
                            title: topic,
                            subtitle: 'Quiz z $topic',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9EEBB0), Color(0xFF66D76A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              // otwórz interaktywny quiz (Kahoot-style) dla wybranego tematu
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InteractiveQuizPage(course: title, topic: topic),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList()
                    else
                      const Text(
                        'Lista quizów będzie dostępna wkrótce.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    const SizedBox(height: 20),
                    // tymczasowy placeholder
                    const Text(
                      'Opis: tutaj będzie zawartość kursu — lekcje, moduły i postęp.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 120),
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

/// Prosty, spójny wizualnie TopicTile
class TopicTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const TopicTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 2, offset: const Offset(-2, -2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
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