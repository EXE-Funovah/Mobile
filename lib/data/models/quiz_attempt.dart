import 'user_stats.dart';

/// 1 câu trả lời đã chọn — backend tự chấm theo Options.IsCorrect.
class QuizAnswerSubmit {
  final int questionId;
  final int optionId;

  const QuizAnswerSubmit({required this.questionId, required this.optionId});

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'optionId': optionId,
      };
}

/// Body cho `POST /api/QuizAttempt` (server-side scoring).
/// KHÔNG gửi correctCount/totalQuestions — backend tự tính từ answers.
class QuizAttemptSubmitRequest {
  final int quizId;
  final int durationSeconds;
  final List<QuizAnswerSubmit> answers;

  const QuizAttemptSubmitRequest({
    required this.quizId,
    required this.durationSeconds,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'durationSeconds': durationSeconds,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

/// Response của attempt (kèm stats mới nhất nếu vừa submit).
class QuizAttemptDto {
  final int id;
  final int quizId;
  final int correctCount;
  final int totalQuestions;
  final int durationSeconds;
  final int xpEarned;
  final DateTime? completedAt;
  final UserStatsDto? stats;

  const QuizAttemptDto({
    required this.id,
    required this.quizId,
    this.correctCount = 0,
    this.totalQuestions = 0,
    this.durationSeconds = 0,
    this.xpEarned = 0,
    this.completedAt,
    this.stats,
  });

  factory QuizAttemptDto.fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'] ?? json['Stats'];
    return QuizAttemptDto(
      id: _int(json['id'] ?? json['Id']) ?? 0,
      quizId: _int(json['quizId'] ?? json['QuizId']) ?? 0,
      correctCount: _int(json['correctCount'] ?? json['CorrectCount']) ?? 0,
      totalQuestions:
          _int(json['totalQuestions'] ?? json['TotalQuestions']) ?? 0,
      durationSeconds:
          _int(json['durationSeconds'] ?? json['DurationSeconds']) ?? 0,
      xpEarned: _int(json['xpEarned'] ?? json['XpEarned']) ?? 0,
      completedAt: _date(json['completedAt'] ?? json['CompletedAt']),
      stats: rawStats is Map
          ? UserStatsDto.fromJson(Map<String, dynamic>.from(rawStats))
          : null,
    );
  }

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _date(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
