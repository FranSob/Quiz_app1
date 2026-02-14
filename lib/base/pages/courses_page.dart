import 'package:flutter/material.dart';
import 'package:quiz_app1/base/pages/interactive_quiz_page.dart';

class CoursePage extends StatefulWidget {
  final String title;

  const CoursePage({
    super.key,
    required this.title,
  });

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
    int? _selectedGrade;

  // ================= TEMATY =================

  List<QuizTopic> _bioTopics() => const [
        QuizTopic(title: 'Komórki', grade: 1),
        QuizTopic(title: 'Genetyka', grade: 2),
        QuizTopic(title: 'Ekologia', grade: 3),
      ];


  List<QuizTopic> _mathTopics() => const [
        QuizTopic(title: 'Arytmetyka', grade: 1),
        QuizTopic(title: 'Algebra', grade: 2),
      ];

  List<QuizTopic> _chemTopics() => const [
        QuizTopic(title: 'Organiczna', grade: 3),
        QuizTopic(title: 'Nieorganiczna', grade: 4),
      ];

  // ================= THEME =================

  Map<String, dynamic> _themeFor(String title) {
    final key = title.toLowerCase();
    if (key.contains('bio')) {
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
    } else if (key.contains('matem') || key.contains('math')) {
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

  // ================= UI =================

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
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Szukaj quizu...',
            hintStyle: TextStyle(color: Colors.white38),
            icon: Icon(Icons.search, color: Colors.white54),
          ),
        ),
      ),
    );
  }
Widget buildGradeFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Wszystkie'),
            selected: _selectedGrade == null,
            onSelected: (_) => setState(() => _selectedGrade = null),
            selectedColor: const Color(0xFF6A5AE0),
            backgroundColor: const Color(0xFF1C1C28),
            labelStyle: TextStyle(color: _selectedGrade == null ? Colors.white : Colors.white70),
          ),
          ...List.generate(4, (i) {
            final grade = i + 1;
            return ChoiceChip(
              label: Text('Klasa $grade'),
              selected: _selectedGrade == grade,
              onSelected: (_) => setState(() => _selectedGrade = grade),
              selectedColor: const Color(0xFF6A5AE0),
              backgroundColor: const Color(0xFF1C1C28),
              labelStyle: TextStyle(color: _selectedGrade == grade ? Colors.white : Colors.white70),
            );
          }),
        ],
      ),
    );
  }

  // helper: wybiera gradient kafelka na podstawie kursu (daje pasujący akcent)
  LinearGradient _tileGradientForCourse(String courseTitle) {
    final key = courseTitle.toLowerCase();
    if (key.contains('bio')) {
      return const LinearGradient(
        colors: [Color(0xFF9EEBB0), Color(0xFF66D76A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (key.contains('matem') || key.contains('math')) {
      return const LinearGradient(
        colors: [Color(0xFF4CA1FF), Color(0xFF0072FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (key.contains('chem')) {
      return const LinearGradient(
        colors: [Color(0xFFFF9A8B), Color(0xFFFBCB0A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF6A5AE0), Color(0xFF4D4AE8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(widget.title);
    final IconData icon = theme['icon'];
    final LinearGradient gradient = theme['gradient'];

    final titleLower = widget.title.toLowerCase();

   List<QuizTopic> topics = [];
    if (titleLower.contains('bio')) topics = _bioTopics();
    if (titleLower.contains('matem')) topics = _mathTopics();
    if (titleLower.contains('chem')) topics = _chemTopics();

    final filteredTopics = topics
      .where((t) => t.title.toLowerCase().contains(_searchQuery))
        .where((t) => _selectedGrade == null || t.grade == _selectedGrade)
    .toList();

    // gradient dla kafelków (ten sam dla wszystkich tematów w kursie)
    final tileGradient = _tileGradientForCourse(widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCourseHeader(
              title: widget.title,
              icon: icon,
              gradient: gradient,
            ),
            buildQuizSearchBar(),
            buildGradeFilter(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dostępne quizy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredTopics.isNotEmpty)
                    ...filteredTopics.map(
                      (topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TopicTile(
                          title: topic.title,
                          subtitle: 'Quiz z ${topic.title}',
                          grade: topic.grade,
                          gradient: tileGradient,
                          onTap: () {
                            print('Start quiz: course=${widget.title}, topic=$topic');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InteractiveQuizPage(
                                  course: widget.title,
                                  topic: topic.title,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    const Text(
                      'Brak quizów dla tego wyszukiwania.',
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TILE =================

class TopicTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int grade;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const TopicTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.grade,
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
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70)),
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
              child: Text(
                'Klasa $grade',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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

class QuizTopic {
  final String title;
  final int grade;

  const QuizTopic({required this.title, required this.grade});
}
