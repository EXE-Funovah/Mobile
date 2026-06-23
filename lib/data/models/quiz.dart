class QuizDto {
  final int id;
  final int documentId;
  final String title;
  final String status;
  final DateTime? createdAt;
  final bool isDeleted;

  const QuizDto({
    required this.id,
    required this.documentId,
    required this.title,
    required this.status,
    this.createdAt,
    this.isDeleted = false,
  });

  factory QuizDto.fromJson(Map<String, dynamic> json) {
    return QuizDto(
      id: json['id'] ?? json['Id'] ?? 0,
      documentId: json['documentId'] ?? json['DocumentId'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      status: json['status'] ?? json['Status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isDeleted: (json['isDeleted'] ?? json['IsDeleted']) == true,
    );
  }
}

class QuestionDto {
  final int id;
  final int quizId;
  final String questionText;
  final String questionType;
  final List<OptionDto> options;

  const QuestionDto({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    required this.options,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] ?? json['Options'] ?? const [];
    return QuestionDto(
      id: json['id'] ?? json['Id'] ?? 0,
      quizId: json['quizId'] ?? json['QuizId'] ?? 0,
      questionText: json['questionText'] ?? json['QuestionText'] ?? '',
      questionType: json['questionType'] ?? json['QuestionType'] ?? '',
      options: (opts as List)
          .map((o) => OptionDto.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList(),
    );
  }
}

class OptionDto {
  final int id;
  final int questionId;
  final String optionText;
  final bool isCorrect;

  const OptionDto({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory OptionDto.fromJson(Map<String, dynamic> json) {
    return OptionDto(
      id: json['id'] ?? json['Id'] ?? 0,
      questionId: json['questionId'] ?? json['QuestionId'] ?? 0,
      optionText: json['optionText'] ?? json['OptionText'] ?? '',
      isCorrect: (json['isCorrect'] ?? json['IsCorrect']) == true,
    );
  }
}

class GeneratedQuestionDto {
  final String questionText;
  final String questionType;
  final List<GeneratedOptionDto> options;

  const GeneratedQuestionDto({
    required this.questionText,
    required this.questionType,
    required this.options,
  });

  factory GeneratedQuestionDto.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] ?? json['Options'] ?? const [];
    return GeneratedQuestionDto(
      questionText: json['questionText'] ?? json['QuestionText'] ?? '',
      questionType:
          json['questionType'] ?? json['QuestionType'] ?? 'MultipleChoice',
      options: (opts as List)
          .map(
            (o) => GeneratedOptionDto.fromJson(
              Map<String, dynamic>.from(o as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'questionType': questionType,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class GeneratedOptionDto {
  final String optionText;
  final bool isCorrect;

  const GeneratedOptionDto({required this.optionText, required this.isCorrect});

  factory GeneratedOptionDto.fromJson(Map<String, dynamic> json) {
    return GeneratedOptionDto(
      optionText: json['optionText'] ?? json['OptionText'] ?? '',
      isCorrect: (json['isCorrect'] ?? json['IsCorrect']) == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'optionText': optionText, 'isCorrect': isCorrect};
  }
}
