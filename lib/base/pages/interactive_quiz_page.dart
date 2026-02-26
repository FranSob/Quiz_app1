import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app1/base/models/quiz_question.dart';
import 'package:quiz_app1/config.dart';
import 'package:quiz_app1/services/quiz_api.dart';
import 'package:quiz_app1/services/quiz_stats_storage.dart';
import 'package:quiz_app1/services/unfinished_quiz_storage.dart';

class InteractiveQuizPage extends StatefulWidget {
  final String course;
  final String topic; // optional: can be empty to fetch whole course
  final UnfinishedQuizProgress? initialProgress;

  const InteractiveQuizPage({super.key, required this.course, required this.topic, this.initialProgress});

  @override
  State<InteractiveQuizPage> createState() => _InteractiveQuizPageState();
}

class _InteractiveQuizPageState extends State<InteractiveQuizPage> {
  late final QuizApi api;
  final UnfinishedQuizStorage _unfinishedQuizStorage = UnfinishedQuizStorage();
  List<QuizQuestion> questions = [];
  bool loading = true;
  String? error;

  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  int? selectedIndex;
  Timer? _nextTimer;
  bool _resultRecorded = false;

  @override
  void initState() {
    super.initState();
    api = QuizApi(baseUrl: resolveApiBaseUrl());
    _loadQuestions();
  }

  Widget _buildOption(int i, String text) {
    // defensive guard: jeśli lista pytań jest pusta lub currentIndex poza zakresem -> nic nie rysujemy
    if (questions.isEmpty || currentIndex < 0 || currentIndex >= questions.length) {
      return const SizedBox.shrink();
    }

    final qi = questions[currentIndex];
    // dodatkowa kontrola: jeśli indeks opcji poza zakresem, zwróć pusty widget
    if (i < 0 || i >= qi.options.length) return const SizedBox.shrink();

    final correct = qi.correctIndex == i;
    Color bgColor = const Color(0xFF2A2A32); // neutral
    Color borderColor = Colors.white24;

    if (answered) {
      if (selectedIndex == i) {
        bgColor = (correct ? Colors.green[600]! : Colors.redAccent);
        borderColor = Colors.transparent;
      } else if (correct) {
        // highlight correct even if not selected
        bgColor = Colors.green[700]!.withOpacity(0.9);
      } else {
        bgColor = const Color(0xFF2A2A32);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: InkWell(
        onTap: () => _onSelect(i),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
              if (answered && (correct || selectedIndex == i))
                Icon(
                  correct ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nextTimer?.cancel();
    super.dispose();
  }

  QuizQuestion _parseQuestionMap(Map<String, dynamic> m) {
    final question = m['question'] as String;
    final List<dynamic> optsDyn = m['options'] as List<dynamic>;
    final options = optsDyn.map((e) => e.toString()).toList();

    if (m.containsKey('correctIndex')) {
      final idx = (m['correctIndex'] as num).toInt();
      return QuizQuestion(question: question, options: options, correctIndex: idx);
    } else if (m.containsKey('answer')) {
      final answer = m['answer'].toString();
      final idx = options.indexOf(answer);
      return QuizQuestion(
        question: question,
        options: options,
        correctIndex: idx >= 0 ? idx : 0,
      );
    } else {
      return QuizQuestion(question: question, options: options, correctIndex: 0);
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      loading = true;
      error = null;
    });

    final base = api.baseUrl;
    final courseEnc = Uri.encodeComponent(widget.course);
    final topicEnc = Uri.encodeComponent(widget.topic);

    try {
      List<QuizQuestion> loaded = [];

      if (widget.topic.isNotEmpty) {
        final urlTopic = Uri.parse('$base/quiz/$courseEnc/$topicEnc');
        final resTopic = await http.get(urlTopic);

        if (resTopic.statusCode == 200) {
          final decoded = jsonDecode(resTopic.body);
          if (decoded is List) {
            loaded = decoded
                .map((e) => _parseQuestionMap(e as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Niepoprawny format danych (nie jest listą)');
          }
        } else {
          throw Exception(
              'Endpoint nie istnieje (${resTopic.statusCode})\nURL: $urlTopic');
        }
      } else {
        final urlCourse = Uri.parse('$base/quiz/$courseEnc');
        final resCourse = await http.get(urlCourse);

        if (resCourse.statusCode == 200) {
          final decoded = jsonDecode(resCourse.body);
          if (decoded is List) {
            loaded = decoded
                .map((e) => _parseQuestionMap(e as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Niepoprawny format danych (nie jest listą)');
          }
        } else {
          throw Exception(
              'Endpoint nie istnieje (${resCourse.statusCode})\nURL: $urlCourse');
        }
      }

      if (loaded.isEmpty) {
        throw Exception(
            'Brak pytań dla:\nKurs: ${widget.course}\nTemat: ${widget.topic}');
      }

      if (mounted) {
        final restored = widget.initialProgress;
        final restoredIndex = restored == null
            ? 0
            : restored.currentIndex.clamp(0, loaded.length - 1).toInt();
        setState(() {
          questions = loaded;
          currentIndex = restoredIndex;
          score = restored?.score ?? 0;
          loading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR: $e');

      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  void _onSelect(int idx) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedIndex = idx;
      if (idx == questions[currentIndex].correctIndex) score++;
    });

    _nextTimer = Timer(const Duration(milliseconds: 800), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          answered = false;
          selectedIndex = null;
        });
      } else {
        _recordStatsAndShowResult();
      }
    });
  }

  Future<void> _recordStatsAndShowResult() async {
    if (_resultRecorded) {
      _showResultDialog();
      return;
    }

    _resultRecorded = true;

    try {
      await _unfinishedQuizStorage.remove(course: widget.course, topic: widget.topic);

      await QuizStatsStorage().recordQuizCompletion(
        course: widget.course,
        score: score,
        totalQuestions: questions.length,
      );
    } catch (e) {
      print('❌ ERROR recording stats: $e');
    }

    if (!mounted) return;
    _showResultDialog();
  }

  Future<void> _saveAsUnfinishedAndExit() async {
    if (loading || questions.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final progress = UnfinishedQuizProgress(
      course: widget.course,
      topic: widget.topic,
      currentIndex: currentIndex,
      score: score,
      totalQuestions: questions.length,
      updatedAt: DateTime.now(),
    );

    await _unfinishedQuizStorage.save(progress);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<bool> _confirmAbandonQuiz() async {
    final shouldAbandon = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C28),
            title: const Text('Porzucić quiz?',
                style: TextStyle(color: Colors.white)),
            content: const Text(
              'Czy napewno chcesz porzucić ten kurs?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                child: const Text('Porzuć'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldAbandon) {
      await _saveAsUnfinishedAndExit();
      return false;
    }

    return false;
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C28),
        title: const Text('Wynik', style: TextStyle(color: Colors.white)),
        content: Text(
          'Twój wynik: $score / ${questions.length}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Zamknij'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('Zakończ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1C1C28),
            foregroundColor: Colors.white,
            title: Text(widget.topic.isNotEmpty
                ? '${widget.course} • ${widget.topic}'
                : widget.course)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // guard: jeśli z jakiegoś powodu nie ma pytań — pokaż informację zamiast crasha
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1C1C28),
            foregroundColor: Colors.white,
            title: Text(widget.topic.isNotEmpty
                ? '${widget.course} • ${widget.topic}'
                : widget.course)),
        body: const Center(child: Text('Brak pytań.', style: TextStyle(color: Colors.white70))),
      );
    }

    final q = questions[currentIndex.clamp(0, questions.length - 1).toInt()];

    return WillPopScope(
      onWillPop: _confirmAbandonQuiz,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1C28),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _confirmAbandonQuiz();
            },
          ),
          title: Text(widget.topic.isNotEmpty
              ? '${widget.course} • ${widget.topic}'
              : widget.course),
        ),
        body: Column(
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text('${currentIndex + 1} / ${questions.length}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      backgroundColor: Colors.white12,
                      color: Colors.green,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (context, i) {
                  return _buildOption(i, q.options[i]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}