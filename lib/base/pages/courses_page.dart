import 'package:flutter/material.dart';
import '../../base/models/quiz.dart';
import '../../services/quiz_service.dart';
import '../widgets/quiz_tile.dart';

class CoursePage extends StatelessWidget {
  final String title;

  const CoursePage({super.key, required this.title});

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Dostępne quizy',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Quiz>>(
                      future: QuizService.fetchQuizzes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            'Błąd ładowania quizów',
                            style: TextStyle(color: Colors.redAccent),
                          );
                        }
                        final quizzes = snapshot.data
                                ?.where((q) => q.course.toLowerCase().contains(title.toLowerCase()))
                                .toList() ??
                            [];
                        if (quizzes.isEmpty) {
                          return const Text(
                            'Brak quizów dla tego kursu',
                            style: TextStyle(color: Colors.white54),
                          );
                        }
                        return Column(
                          children: quizzes.map((q) => QuizTile(quiz: q)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 200),
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
