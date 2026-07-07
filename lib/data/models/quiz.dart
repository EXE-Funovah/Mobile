class QuizDto {
  final int id;
  final int documentId;
  final String title;
  final String status;
  final String activityType; // "Quiz" | "Flashcard"
  final int questionCount;
  final DateTime? createdAt;
  final bool isDeleted;

  const QuizDto({
    required this.id,
    required this.documentId,
    required this.title,
    required this.status,
    this.activityType = 'Quiz',
    this.questionCount = 0,
    this.createdAt,
    this.isDeleted = false,
  });

  factory QuizDto.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] ?? json['CreatedAt'];
    return QuizDto(
      id: json['id'] ?? json['Id'] ?? 0,
      documentId: json['documentId'] ?? json['DocumentId'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      status: json['status'] ?? json['Status'] ?? '',
      activityType: json['activityType'] ?? json['ActivityType'] ?? 'Quiz',
      questionCount: json['questionCount'] ?? json['QuestionCount'] ?? 0,
      createdAt: created != null ? DateTime.tryParse(created.toString()) : null,
      isDeleted: (json['isDeleted'] ?? json['IsDeleted']) == true,
    );
  }

  bool get isFlashcard => activityType == 'Flashcard';
}

/// Chi tiết 1 bộ (Quiz hoặc Flashcard) kèm câu hỏi đã sort theo `position`.
/// Map từ `QuizDetailResponse` của backend (`GET /api/Quiz/{id}/detail`).
class QuizDetailDto {
  final int id;
  final int documentId;
  final String title;
  final String activityType;
  final String status;
  final DateTime? createdAt;
  final List<QuestionDto> questions;

  const QuizDetailDto({
    required this.id,
    required this.documentId,
    required this.title,
    required this.activityType,
    required this.status,
    this.createdAt,
    this.questions = const [],
  });

  factory QuizDetailDto.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] ?? json['CreatedAt'];
    final qs = json['questions'] ?? json['Questions'] ?? const [];
    final questions = (qs as List)
        .map((q) => QuestionDto.fromJson(Map<String, dynamic>.from(q as Map)))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return QuizDetailDto(
      id: json['id'] ?? json['Id'] ?? 0,
      documentId: json['documentId'] ?? json['DocumentId'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      activityType: json['activityType'] ?? json['ActivityType'] ?? 'Quiz',
      status: json['status'] ?? json['Status'] ?? '',
      createdAt: created != null ? DateTime.tryParse(created.toString()) : null,
      questions: questions,
    );
  }
}

class QuestionDto {
  final int id;
  final int quizId;
  final String questionText;
  final String questionType;
  final int position;
  final List<OptionDto> options;

  const QuestionDto({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.position = 0,
    required this.options,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] ?? json['Options'] ?? const [];
    return QuestionDto(
      id: json['id'] ?? json['Id'] ?? 0,
      quizId: json['quizId'] ?? json['QuizId'] ?? 0,
      questionText: json['questionText'] ?? json['QuestionText'] ?? '',
      questionType: json['questionType'] ?? json['QuestionType'] ?? '',
      position: json['position'] ?? json['Position'] ?? 0,
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
