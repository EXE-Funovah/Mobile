// Models khớp DTO backend `/api/Admin/*` (JSON camelCase, System.Text.Json).

double _toD(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _toI(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

class AdminKpi {
  final String key;
  final String label;
  final double value;
  final String format; // int | currency | percent
  final double deltaPercent;
  final bool up;

  AdminKpi({
    required this.key,
    required this.label,
    required this.value,
    required this.format,
    required this.deltaPercent,
    required this.up,
  });

  factory AdminKpi.fromJson(Map j) => AdminKpi(
    key: '${j['key'] ?? ''}',
    label: '${j['label'] ?? ''}',
    value: _toD(j['value']),
    format: '${j['format'] ?? 'int'}',
    deltaPercent: _toD(j['deltaPercent']),
    up: j['up'] == true,
  );
}

class NamedValue {
  final String label;
  final num value;
  final String? color;
  NamedValue({required this.label, required this.value, this.color});
  factory NamedValue.fromJson(Map j) => NamedValue(
    label: '${j['label'] ?? ''}',
    value: _toD(j['value']),
    color: j['color']?.toString(),
  );
}

class MonthPoint {
  final String label;
  final num value;
  MonthPoint({required this.label, required this.value});
  factory MonthPoint.fromJson(Map j) =>
      MonthPoint(label: '${j['label'] ?? ''}', value: _toD(j['value']));
}

/// `GET /api/Admin/overview` → AdminOverviewResponse.
class AdminOverview {
  final String range;
  final List<AdminKpi> kpis;
  final List<NamedValue> userDistribution;
  final List<NamedValue> subscriptionDistribution;
  final List<NamedValue> contentTotals;
  final List<NamedValue> paymentStatusDistribution;
  final List<MonthPoint> paidRevenueSeries;

  AdminOverview({
    required this.range,
    required this.kpis,
    required this.userDistribution,
    required this.subscriptionDistribution,
    required this.contentTotals,
    required this.paymentStatusDistribution,
    required this.paidRevenueSeries,
  });

  static List<NamedValue> _nv(dynamic v) =>
      (v as List? ?? []).map((e) => NamedValue.fromJson(e)).toList();

  factory AdminOverview.fromJson(Map j) => AdminOverview(
    range: '${j['range'] ?? ''}',
    kpis: (j['kpis'] as List? ?? []).map((e) => AdminKpi.fromJson(e)).toList(),
    userDistribution: _nv(j['userDistribution']),
    subscriptionDistribution: _nv(j['subscriptionDistribution']),
    contentTotals: _nv(j['contentTotals']),
    paymentStatusDistribution: _nv(j['paymentStatusDistribution']),
    paidRevenueSeries: (j['paidRevenueSeries'] as List? ?? [])
        .map((e) => MonthPoint.fromJson(e))
        .toList(),
  );
}

/// 1 user trong `GET /api/Admin/users` (AdminUserListItemDto).
class AdminUserItem {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String subscriptionTier;
  final String subscriptionStatus; // Freemium | Premium | Expired
  final String? premiumExpiresAt;
  final String? createdAt;
  final String? lastActiveDate;
  final int documentCount;
  final int quizCount;
  final int flashcardCount;
  final int liveSessionCount;

  AdminUserItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.subscriptionTier,
    required this.subscriptionStatus,
    required this.premiumExpiresAt,
    required this.createdAt,
    required this.lastActiveDate,
    required this.documentCount,
    required this.quizCount,
    required this.flashcardCount,
    required this.liveSessionCount,
  });

  factory AdminUserItem.fromJson(Map j) => AdminUserItem(
    id: _toI(j['id']),
    fullName: '${j['fullName'] ?? ''}',
    email: '${j['email'] ?? ''}',
    role: '${j['role'] ?? ''}',
    subscriptionTier: '${j['subscriptionTier'] ?? ''}',
    subscriptionStatus: '${j['subscriptionStatus'] ?? ''}',
    premiumExpiresAt: j['premiumExpiresAt']?.toString(),
    createdAt: j['createdAt']?.toString(),
    lastActiveDate: j['lastActiveDate']?.toString(),
    documentCount: _toI(j['documentCount']),
    quizCount: _toI(j['quizCount']),
    flashcardCount: _toI(j['flashcardCount']),
    liveSessionCount: _toI(j['liveSessionCount']),
  );
}

class AdminUsers {
  final int page;
  final int pageSize;
  final int total;
  final List<AdminUserItem> items;
  AdminUsers({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminUsers.fromJson(Map j) => AdminUsers(
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminUserItem.fromJson(e))
        .toList(),
  );
}

/// `GET /api/Admin/users/{id}` (AdminUserDetailResponse) — kế thừa user + số liệu.
class AdminUserDetail extends AdminUserItem {
  final int documentsProcessed;
  final int xp;
  final int currentStreak;
  final int totalLearningSeconds;
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;
  final int paymentOrderCount;
  final String? latestPaymentStatus;
  final String? latestPaymentPlanCode;
  final String? latestPaymentAt;

  AdminUserDetail({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    required super.subscriptionTier,
    required super.subscriptionStatus,
    required super.premiumExpiresAt,
    required super.createdAt,
    required super.lastActiveDate,
    required super.documentCount,
    required super.quizCount,
    required super.flashcardCount,
    required super.liveSessionCount,
    required this.documentsProcessed,
    required this.xp,
    required this.currentStreak,
    required this.totalLearningSeconds,
    required this.totalCorrectAnswers,
    required this.totalQuestionsAnswered,
    required this.paymentOrderCount,
    required this.latestPaymentStatus,
    required this.latestPaymentPlanCode,
    required this.latestPaymentAt,
  });

  factory AdminUserDetail.fromJson(Map j) => AdminUserDetail(
    id: _toI(j['id']),
    fullName: '${j['fullName'] ?? ''}',
    email: '${j['email'] ?? ''}',
    role: '${j['role'] ?? ''}',
    subscriptionTier: '${j['subscriptionTier'] ?? ''}',
    subscriptionStatus: '${j['subscriptionStatus'] ?? ''}',
    premiumExpiresAt: j['premiumExpiresAt']?.toString(),
    createdAt: j['createdAt']?.toString(),
    lastActiveDate: j['lastActiveDate']?.toString(),
    documentCount: _toI(j['documentCount']),
    quizCount: _toI(j['quizCount']),
    flashcardCount: _toI(j['flashcardCount']),
    liveSessionCount: _toI(j['liveSessionCount']),
    documentsProcessed: _toI(j['documentsProcessed']),
    xp: _toI(j['xp']),
    currentStreak: _toI(j['currentStreak']),
    totalLearningSeconds: _toI(j['totalLearningSeconds']),
    totalCorrectAnswers: _toI(j['totalCorrectAnswers']),
    totalQuestionsAnswered: _toI(j['totalQuestionsAnswered']),
    paymentOrderCount: _toI(j['paymentOrderCount']),
    latestPaymentStatus: j['latestPaymentStatus']?.toString(),
    latestPaymentPlanCode: j['latestPaymentPlanCode']?.toString(),
    latestPaymentAt: j['latestPaymentAt']?.toString(),
  );
}

/// 1 tài liệu trong `GET /api/Admin/documents` (AdminDocumentItemDto).
class AdminDocumentItem {
  final int id;
  final String? fileName;
  final String? uploadedAt;
  final bool isDeleted;
  final int ownerId;
  final String ownerName;
  final String ownerEmail;
  final bool ownerIsDeleted;
  final int quizCount;
  final int flashcardCount;

  AdminDocumentItem({
    required this.id,
    required this.fileName,
    required this.uploadedAt,
    required this.isDeleted,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerIsDeleted,
    required this.quizCount,
    required this.flashcardCount,
  });

  factory AdminDocumentItem.fromJson(Map j) => AdminDocumentItem(
    id: _toI(j['id']),
    fileName: j['fileName']?.toString(),
    uploadedAt: j['uploadedAt']?.toString(),
    isDeleted: j['isDeleted'] == true,
    ownerId: _toI(j['ownerId']),
    ownerName: '${j['ownerName'] ?? ''}',
    ownerEmail: '${j['ownerEmail'] ?? ''}',
    ownerIsDeleted: j['ownerIsDeleted'] == true,
    quizCount: _toI(j['quizCount']),
    flashcardCount: _toI(j['flashcardCount']),
  );
}

class AdminDocuments {
  final int page, pageSize, total;
  final List<AdminDocumentItem> items;
  AdminDocuments({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminDocuments.fromJson(Map j) => AdminDocuments(
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminDocumentItem.fromJson(e))
        .toList(),
  );
}

/// 1 quiz/flashcard trong `GET /api/Admin/quizzes` (AdminQuizItemDto).
class AdminQuizItem {
  final int id;
  final String title;
  final String activityType; // Quiz | Flashcard
  final String status; // AI_Drafted | Teacher_Approved | Published
  final String? createdAt;
  final bool isDeleted;
  final int questionCount;
  final int documentId;
  final String? documentFileName;
  final bool documentIsDeleted;
  final int ownerId;
  final String ownerName;
  final String ownerEmail;
  final bool ownerIsDeleted;

  AdminQuizItem({
    required this.id,
    required this.title,
    required this.activityType,
    required this.status,
    required this.createdAt,
    required this.isDeleted,
    required this.questionCount,
    required this.documentId,
    required this.documentFileName,
    required this.documentIsDeleted,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerIsDeleted,
  });

  bool get isQuiz => activityType == 'Quiz';

  factory AdminQuizItem.fromJson(Map j) => AdminQuizItem(
    id: _toI(j['id']),
    title: '${j['title'] ?? ''}',
    activityType: '${j['activityType'] ?? 'Quiz'}',
    status: '${j['status'] ?? ''}',
    createdAt: j['createdAt']?.toString(),
    isDeleted: j['isDeleted'] == true,
    questionCount: _toI(j['questionCount']),
    documentId: _toI(j['documentId']),
    documentFileName: j['documentFileName']?.toString(),
    documentIsDeleted: j['documentIsDeleted'] == true,
    ownerId: _toI(j['ownerId']),
    ownerName: '${j['ownerName'] ?? ''}',
    ownerEmail: '${j['ownerEmail'] ?? ''}',
    ownerIsDeleted: j['ownerIsDeleted'] == true,
  );
}

class AdminQuizzes {
  final int page, pageSize, total;
  final List<AdminQuizItem> items;
  AdminQuizzes({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminQuizzes.fromJson(Map j) => AdminQuizzes(
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminQuizItem.fromJson(e))
        .toList(),
  );
}

/// 1 phiên live trong `GET /api/Admin/sessions` (AdminSessionItemDto).
class AdminSessionItem {
  final int id;
  final String gamePin;
  final String status; // Waiting | Active | Ended
  final String? createdAt;
  final bool isDeleted;
  final int teacherId;
  final String teacherName;
  final String teacherEmail;
  final bool teacherIsDeleted;
  final int quizId;
  final String quizTitle;
  final String quizActivityType;
  final String templateName;
  final int participantCount;

  AdminSessionItem({
    required this.id,
    required this.gamePin,
    required this.status,
    required this.createdAt,
    required this.isDeleted,
    required this.teacherId,
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherIsDeleted,
    required this.quizId,
    required this.quizTitle,
    required this.quizActivityType,
    required this.templateName,
    required this.participantCount,
  });

  factory AdminSessionItem.fromJson(Map j) => AdminSessionItem(
    id: _toI(j['id']),
    gamePin: '${j['gamePin'] ?? ''}',
    status: '${j['status'] ?? ''}',
    createdAt: j['createdAt']?.toString(),
    isDeleted: j['isDeleted'] == true,
    teacherId: _toI(j['teacherId']),
    teacherName: '${j['teacherName'] ?? ''}',
    teacherEmail: '${j['teacherEmail'] ?? ''}',
    teacherIsDeleted: j['teacherIsDeleted'] == true,
    quizId: _toI(j['quizId']),
    quizTitle: '${j['quizTitle'] ?? ''}',
    quizActivityType: '${j['quizActivityType'] ?? ''}',
    templateName: '${j['templateName'] ?? ''}',
    participantCount: _toI(j['participantCount']),
  );
}

class AdminSessions {
  final int page, pageSize, total;
  final List<AdminSessionItem> items;
  AdminSessions({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminSessions.fromJson(Map j) => AdminSessions(
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminSessionItem.fromJson(e))
        .toList(),
  );
}

/// Người tham gia phiên (AdminSessionParticipantDto).
class AdminParticipant {
  final int id;
  final int sessionId;
  final String studentName;
  final int? totalScore;
  final bool isDeleted;
  AdminParticipant({
    required this.id,
    required this.sessionId,
    required this.studentName,
    required this.totalScore,
    required this.isDeleted,
  });
  factory AdminParticipant.fromJson(Map j) => AdminParticipant(
    id: _toI(j['id']),
    sessionId: _toI(j['sessionId']),
    studentName: '${j['studentName'] ?? ''}',
    totalScore: j['totalScore'] == null ? null : _toI(j['totalScore']),
    isDeleted: j['isDeleted'] == true,
  );
}

class AdminParticipants {
  final int sessionId, page, pageSize, total;
  final List<AdminParticipant> items;
  AdminParticipants({
    required this.sessionId,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminParticipants.fromJson(Map j) => AdminParticipants(
    sessionId: _toI(j['sessionId']),
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminParticipant.fromJson(e))
        .toList(),
  );
}

/// 1 đơn thanh toán trong `GET /api/Admin/billing/orders` + `/{id}` (AdminPaymentOrderItemDto).
class AdminPaymentOrder {
  final int id;
  final int userId;
  final int orderCode;
  final String planCode;
  final int amount;
  final String currency;
  final String status; // Pending | Paid | Cancelled | Expired | Failed
  final String provider;
  final String? payosReference;
  final String? paidAt;
  final String? cancelledAt;
  final String createdAt;
  final String? updatedAt;
  final bool isDeleted;
  final String userName;
  final String userEmail;
  final bool userIsDeleted;
  final String subscriptionTier;
  final String? premiumExpiresAt;
  final bool isPremiumActive;

  AdminPaymentOrder({
    required this.id,
    required this.userId,
    required this.orderCode,
    required this.planCode,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    required this.payosReference,
    required this.paidAt,
    required this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.userName,
    required this.userEmail,
    required this.userIsDeleted,
    required this.subscriptionTier,
    required this.premiumExpiresAt,
    required this.isPremiumActive,
  });

  factory AdminPaymentOrder.fromJson(Map j) => AdminPaymentOrder(
    id: _toI(j['id']),
    userId: _toI(j['userId']),
    orderCode: _toI(j['orderCode']),
    planCode: '${j['planCode'] ?? ''}',
    amount: _toI(j['amount']),
    currency: '${j['currency'] ?? 'VND'}',
    status: '${j['status'] ?? ''}',
    provider: '${j['provider'] ?? ''}',
    payosReference: j['payosReference']?.toString(),
    paidAt: j['paidAt']?.toString(),
    cancelledAt: j['cancelledAt']?.toString(),
    createdAt: '${j['createdAt'] ?? ''}',
    updatedAt: j['updatedAt']?.toString(),
    isDeleted: j['isDeleted'] == true,
    userName: '${j['userName'] ?? ''}',
    userEmail: '${j['userEmail'] ?? ''}',
    userIsDeleted: j['userIsDeleted'] == true,
    subscriptionTier: '${j['subscriptionTier'] ?? ''}',
    premiumExpiresAt: j['premiumExpiresAt']?.toString(),
    isPremiumActive: j['isPremiumActive'] == true,
  );
}

class AdminPaymentOrders {
  final int page, pageSize, total;
  final List<AdminPaymentOrder> items;
  AdminPaymentOrders({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminPaymentOrders.fromJson(Map j) => AdminPaymentOrders(
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminPaymentOrder.fromJson(e))
        .toList(),
  );
}

/// Webhook PayOS (AdminWebhookEventItemDto).
class AdminWebhookEvent {
  final int id;
  final String provider;
  final int? orderCode;
  final String? reference;
  final String? processedAt;
  final bool isProcessed;
  final String? processingError;
  AdminWebhookEvent({
    required this.id,
    required this.provider,
    required this.orderCode,
    required this.reference,
    required this.processedAt,
    required this.isProcessed,
    required this.processingError,
  });
  factory AdminWebhookEvent.fromJson(Map j) => AdminWebhookEvent(
    id: _toI(j['id']),
    provider: '${j['provider'] ?? ''}',
    orderCode: j['orderCode'] == null ? null : _toI(j['orderCode']),
    reference: j['reference']?.toString(),
    processedAt: j['processedAt']?.toString(),
    isProcessed: j['isProcessed'] == true,
    processingError: j['processingError']?.toString(),
  );
}

class AdminWebhookEvents {
  final int page, pageSize, total;
  final List<AdminWebhookEvent> items;
  AdminWebhookEvents({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });
  factory AdminWebhookEvents.fromJson(Map j) => AdminWebhookEvents(
    page: _toI(j['page']),
    pageSize: _toI(j['pageSize']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminWebhookEvent.fromJson(e))
        .toList(),
  );
}
