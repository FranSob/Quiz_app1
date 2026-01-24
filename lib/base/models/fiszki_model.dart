class Fiszka {
  String question;
  String answer;

  Fiszka({required this.question, required this.answer});

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };

  factory Fiszka.fromJson(Map<String, dynamic> json) => Fiszka(
        question: json['question'],
        answer: json['answer'],
      );
}
