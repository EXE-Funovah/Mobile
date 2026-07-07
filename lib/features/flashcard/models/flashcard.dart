/// 1 thẻ ghi nhớ: mặt trước = câu hỏi, mặt sau = đáp án đúng.
/// Cùng dữ liệu với Quiz (front = QuestionText, back = option IsCorrect=true).
class FlashCard {
  final String front;
  final String back;

  const FlashCard({required this.front, required this.back});
}

/// 1 bộ flashcard trong Thư viện + tiến độ học client-side.
class FlashcardSet {
  final int id;
  final int documentId;
  final String title;
  final int count;
  final int learned; // số thẻ "đã thuộc" lưu cục bộ
  final bool isNew; // chưa học thẻ nào

  const FlashcardSet({
    required this.id,
    required this.documentId,
    required this.title,
    required this.count,
    required this.learned,
    required this.isNew,
  });
}

/// Kết quả 1 phiên học lật thẻ.
class FlashcardResult {
  final int total;
  final int known;
  final int review;

  const FlashcardResult({
    required this.total,
    required this.known,
    required this.review,
  });
}
