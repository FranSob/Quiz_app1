import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app1/base/models/quiz_question.dart';

class QuizApi {
  final String baseUrl; // np. 'http://10.0.2.2:3000' dla emulatora Android

  QuizApi({required this.baseUrl});

  Future<List<QuizQuestion>> fetchCourseQuiz(String course) async {
    final url = Uri.parse('$baseUrl/quiz/${Uri.encodeComponent(course)}');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load quiz (${res.statusCode})');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<QuizQuestion>> fetchTopicQuiz(String course, String topic) async {
    final url = Uri.parse('$baseUrl/quiz/${Uri.encodeComponent(course)}/${Uri.encodeComponent(topic)}');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load topic quiz (${res.statusCode})');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>)).toList();
  }
}