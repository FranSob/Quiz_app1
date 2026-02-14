import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SubjectStats {
  final String subject;
  final int completedCount;
  final int correctAnswers;
  final int totalAnswers;

  const SubjectStats({
    required this.subject,
    required this.completedCount,
    required this.correctAnswers,
    required this.totalAnswers,
  });

  double get accuracy => totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

  SubjectStats copyWith({
    int? completedCount,
    int? correctAnswers,
    int? totalAnswers,
  }) {
    return SubjectStats(
      subject: subject,
      completedCount: completedCount ?? this.completedCount,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedCount': completedCount,
        'correctAnswers': correctAnswers,
        'totalAnswers': totalAnswers,
      };

  factory SubjectStats.fromJson(String subject, Map<String, dynamic> json) {
    return SubjectStats(
      subject: subject,
      completedCount: (json['completedCount'] as num? ?? 0).toInt(),
      correctAnswers: (json['correctAnswers'] as num? ?? 0).toInt(),
      totalAnswers: (json['totalAnswers'] as num? ?? 0).toInt(),
    );
  }
}

class QuizStatsStorage {
  static const String _storageKey = 'quizSubjectStats';

  Map<String, SubjectStats> _emptyStats() {
    return {
      'Matematyka': const SubjectStats(
        subject: 'Matematyka',
        completedCount: 0,
        correctAnswers: 0,
        totalAnswers: 0,
      ),
      'Chemia': const SubjectStats(
        subject: 'Chemia',
        completedCount: 0,
        correctAnswers: 0,
        totalAnswers: 0,
      ),
      'Biologia': const SubjectStats(
        subject: 'Biologia',
        completedCount: 0,
        correctAnswers: 0,
        totalAnswers: 0,
      ),
    };
  }

  Future<Map<String, SubjectStats>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return _emptyStats();
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return _emptyStats();
    }

    final mapped = decoded.map(
      (k, v) => MapEntry(
        k,
        SubjectStats.fromJson(
          k,
          (v as Map).cast<String, dynamic>(),
        ),
      ),
    );

    mapped.putIfAbsent(
      'Matematyka',
      () => const SubjectStats(subject: 'Matematyka', completedCount: 0, correctAnswers: 0, totalAnswers: 0),
    );
    mapped.putIfAbsent(
      'Chemia',
      () => const SubjectStats(subject: 'Chemia', completedCount: 0, correctAnswers: 0, totalAnswers: 0),
    );
    mapped.putIfAbsent(
      'Biologia',
      () => const SubjectStats(subject: 'Biologia', completedCount: 0, correctAnswers: 0, totalAnswers: 0),
    );

    return mapped;
  }

  Future<void> recordQuizCompletion({
    required String course,
    required int score,
    required int totalQuestions,
  }) async {
    final stats = await loadStats();
    final normalizedSubject = _normalizeSubject(course);

    if (normalizedSubject == null) {
      return;
    }

    final current = stats[normalizedSubject]!;
    stats[normalizedSubject] = current.copyWith(
      completedCount: current.completedCount + 1,
      correctAnswers: current.correctAnswers + score,
      totalAnswers: current.totalAnswers + totalQuestions,
    );

    final prefs = await SharedPreferences.getInstance();
    final encoded = <String, dynamic>{
      for (final entry in stats.entries) entry.key: entry.value.toJson(),
    };

    await prefs.setString(
      _storageKey,
      jsonEncode(encoded),
    );
  }

  String? _normalizeSubject(String course) {
    final key = course.toLowerCase();
    if (key.contains('matem')) return 'Matematyka';
    if (key.contains('chem')) return 'Chemia';
    if (key.contains('bio')) return 'Biologia';
    return null;
  }
}