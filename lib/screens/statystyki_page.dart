import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_app1/services/quiz_stats_storage.dart';

class StatystykiPage extends StatefulWidget {
  const StatystykiPage({super.key});

  @override
  State<StatystykiPage> createState() => _StatystykiPageState();
}

class _StatystykiPageState extends State<StatystykiPage> {
  final QuizStatsStorage _storage = QuizStatsStorage();
  bool _loading = true;
  late Map<String, SubjectStats> _stats;

  static const Map<String, Color> _subjectColors = {
    'Matematyka': Color(0xFF1E88E5),
    'Chemia': Color(0xFFE53935),
    'Biologia': Color(0xFF43A047),
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final loaded = await _storage.loadStats();
    if (!mounted) return;

    setState(() {
      _stats = loaded;
      _loading = false;
    });
  }

  int get _totalCompletions => _stats.values.fold(0, (sum, item) => sum + item.completedCount);

  String get _mostFrequentSubject {
    final ranked = _stats.values.toList()..sort((a, b) => b.completedCount.compareTo(a.completedCount));
    if (ranked.isEmpty || ranked.first.completedCount == 0) return 'Brak danych';
    return ranked.first.subject;
  }

  String get _bestSubject {
    final active = _stats.values.where((s) => s.completedCount > 0).toList();
    if (active.isEmpty) return 'Brak danych';

    active.sort((a, b) {
      final byAccuracy = b.accuracy.compareTo(a.accuracy);
      if (byAccuracy != 0) return byAccuracy;
      return b.completedCount.compareTo(a.completedCount);
    });

    return active.first.subject;
  }

  double _completionShare(String subject) {
    if (_totalCompletions == 0) return 0;
    return (_stats[subject]?.completedCount ?? 0) / _totalCompletions;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F14),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              const Text(
                'Statystyki',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Twoje postępy quizowe według przedmiotów',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildPieCard(),
              const SizedBox(height: 16),
              _buildAccuracyCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C28),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Podsumowanie', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _summaryRow('Najczęstszy przedmiot', _mostFrequentSubject, Icons.auto_graph_rounded),
          const SizedBox(height: 10),
          _summaryRow('Najlepszy przedmiot', _bestSubject, Icons.emoji_events_rounded),
          const SizedBox(height: 10),
          _summaryRow('Łącznie ukończonych quizów', '$_totalCompletions', Icons.task_alt_rounded),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPieCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C28),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ukończone quizy (%)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _totalCompletions == 0
                ? const Center(
                    child: Text('Brak danych do wykresu.', style: TextStyle(color: Colors.white54)),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _PieChartPainter(
                            values: {
                              for (final s in _stats.values) s.subject: s.completedCount.toDouble(),
                            },
                            colors: _subjectColors,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(width: 132, child: _buildLegend()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _stats.values.map((s) {
        final share = (_completionShare(s.subject) * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _subjectColors[s.subject],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${s.subject}: $share%',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C28),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Poprawność w przedmiotach', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ..._stats.values.map((s) {
            final percent = (s.accuracy * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        s.subject,
                        style: TextStyle(
                          color: _subjectColors[s.subject],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 8,
                      color: _subjectColors[s.subject],
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> values;
  final Map<String, Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.35;
    var startAngle = -pi / 2;

    for (final entry in values.entries) {
      final sweep = 2 * pi * (entry.value / total);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius
        ..strokeCap = StrokeCap.butt
        ..color = colors[entry.key] ?? Colors.white;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }

    final holePaint = Paint()..color = const Color(0xFF1C1C28);
    canvas.drawCircle(center, radius * 0.28, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}