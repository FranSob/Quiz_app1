import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UnfinishedQuizProgress {
  final String course;
  final String topic;
  final int currentIndex;
  final int score;
  final int totalQuestions;
  final DateTime updatedAt;

  const UnfinishedQuizProgress({
    required this.course,
    required this.topic,
    required this.currentIndex,
    required this.score,
    required this.totalQuestions,
    required this.updatedAt,
  });

  String get id => '${course.toLowerCase()}::${topic.toLowerCase()}';

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'topic': topic,
      'currentIndex': currentIndex,
      'score': score,
      'totalQuestions': totalQuestions,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UnfinishedQuizProgress.fromJson(Map<String, dynamic> json) {
    return UnfinishedQuizProgress(
      course: json['course']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      currentIndex: (json['currentIndex'] as num? ?? 0).toInt(),
      score: (json['score'] as num? ?? 0).toInt(),
      totalQuestions: (json['totalQuestions'] as num? ?? 0).toInt(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class UnfinishedQuizStorage {
  static const String _storageKey = 'unfinishedQuizzes';

  Future<List<UnfinishedQuizProgress>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => UnfinishedQuizProgress.fromJson(e.cast<String, dynamic>()))
        .where((e) => e.course.isNotEmpty && e.topic.isNotEmpty)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> save(UnfinishedQuizProgress progress) async {
    final all = await loadAll();
    final filtered = all.where((e) => e.id != progress.id).toList();
    filtered.add(progress);
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(filtered.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> remove({required String course, required String topic}) async {
    final all = await loadAll();
    final id = '${course.toLowerCase()}::${topic.toLowerCase()}';
    final filtered = all.where((e) => e.id != id).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(filtered.map((e) => e.toJson()).toList()),
    );
  }
}