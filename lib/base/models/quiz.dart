class Quiz {
  final String id;
  final String course;
  final String title;
  final int questionCount;

  const Quiz({
    required this.id,
    required this.course,
    required this.title,
    required this.questionCount,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      course: json['course'],
      title: json['title'],
      questionCount: json['questionCount'],
    );
  }
}