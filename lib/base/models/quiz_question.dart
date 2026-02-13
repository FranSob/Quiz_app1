class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({required this.question, required this.options, required this.correctIndex});

  factory QuizQuestion.fromJson(Map<String,dynamic> json) => QuizQuestion(
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List),
    correctIndex: (json['correctIndex'] as num).toInt(),
  );
}