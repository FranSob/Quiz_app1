import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app1/base/models/quiz_question.dart';

class QuizApi {
  final String baseUrl;

  QuizApi({required this.baseUrl});

  // fetch all questions for course
  Future<List<QuizQuestion>> fetchCourseQuiz(String course) async {
    final url = Uri.parse('$baseUrl/quiz/${Uri.encodeComponent(course)}');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load quiz');
    final List data = jsonDecode(res.body);
    return data.map((e) => QuizQuestion.fromJson(e)).toList();
  }

  // fetch quiz for a specific topic
  Future<List<QuizQuestion>> fetchTopicQuiz(String course, String topic) async {
    final url = Uri.parse('$baseUrl/quiz/${Uri.encodeComponent(course)}/${Uri.encodeComponent(topic)}');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load topic quiz');
    final List data = jsonDecode(res.body);
    return data.map((e) => QuizQuestion.fromJson(e)).toList();
  }
}