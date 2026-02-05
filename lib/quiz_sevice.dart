import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base/models/quiz.dart';

class QuizService {
  static const String _baseUrl =
      'https://YOUR_PROJECT.mockapi.io/quizzes';

  static Future<List<Quiz>> fetchQuizzes() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Quiz.fromJson(e)).toList();
    } else {
      throw Exception('Nie udało się pobrać quizów');
    }
  }
}
