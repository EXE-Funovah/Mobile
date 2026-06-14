/// Stats gamification từ `GET /api/UserStats/me` (UserStatResponse C#).
class UserStatsDto {
  final int userId;
  final int xp;
  final int level;
  final int xpToNextLevel;

  /// Giá trị DB — có thể stale nếu user nghỉ lâu.
  final int currentStreak;

  /// Streak để HIỂN THỊ — backend đã tính sẵn (0 nếu đã đứt).
  final int effectiveStreak;

  final int longestStreak;
  final int totalLearningMinutes;
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;
  final double accuracyPercent;

  const UserStatsDto({
    required this.userId,
    this.xp = 0,
    this.level = 1,
    this.xpToNextLevel = 2000,
    this.currentStreak = 0,
    this.effectiveStreak = 0,
    this.longestStreak = 0,
    this.totalLearningMinutes = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestionsAnswered = 0,
    this.accuracyPercent = 0,
  });

  factory UserStatsDto.fromJson(Map<String, dynamic> json) {
    return UserStatsDto(
      userId: _int(json['userId'] ?? json['UserId']) ?? 0,
      xp: _int(json['xp'] ?? json['Xp']) ?? 0,
      level: _int(json['level'] ?? json['Level']) ?? 1,
      xpToNextLevel:
          _int(json['xpToNextLevel'] ?? json['XpToNextLevel']) ?? 2000,
      currentStreak: _int(json['currentStreak'] ?? json['CurrentStreak']) ?? 0,
      effectiveStreak:
          _int(json['effectiveStreak'] ?? json['EffectiveStreak']) ?? 0,
      longestStreak: _int(json['longestStreak'] ?? json['LongestStreak']) ?? 0,
      totalLearningMinutes:
          _int(json['totalLearningMinutes'] ?? json['TotalLearningMinutes']) ??
              0,
      totalCorrectAnswers:
          _int(json['totalCorrectAnswers'] ?? json['TotalCorrectAnswers']) ??
              0,
      totalQuestionsAnswered: _int(
            json['totalQuestionsAnswered'] ?? json['TotalQuestionsAnswered'],
          ) ??
          0,
      accuracyPercent:
          _double(json['accuracyPercent'] ?? json['AccuracyPercent']) ?? 0,
    );
  }

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _double(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
