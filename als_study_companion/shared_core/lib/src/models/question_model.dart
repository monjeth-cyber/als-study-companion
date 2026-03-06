/// Question model for quiz questions.
class QuestionModel {
  final String id;
  final String quizId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final int orderIndex;
  final DateTime createdAt;

  const QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.orderIndex = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'options': options.join('|||'),
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as String,
      quizId: (map['quiz_id'] ?? map['quizId']) as String,
      questionText: (map['question_text'] ?? map['questionText']) as String,
      options: ((map['options'] ?? map['options']) as String).split('|||'),
      correctOptionIndex:
          (map['correct_option_index'] ?? map['correctOptionIndex']) as int,
      explanation: (map['explanation'] as String?),
      orderIndex: (map['order_index'] ?? map['orderIndex']) as int? ?? 0,
      createdAt: DateTime.parse(
        (map['created_at'] ?? map['createdAt']) as String,
      ),
    );
  }

  QuestionModel copyWith({
    String? id,
    String? quizId,
    String? questionText,
    List<String>? options,
    int? correctOptionIndex,
    String? explanation,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
