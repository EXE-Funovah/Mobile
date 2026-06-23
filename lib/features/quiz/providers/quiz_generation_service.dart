import 'dart:typed_data';
import '../../../data/api/ai_api.dart';
import '../../../data/api/document_api.dart';
import '../../../data/api/quiz_api.dart';
import '../../../data/api/question_api.dart';
import '../../../data/models/document.dart';
import '../../../data/models/quiz.dart';

class QuizGenerationResult {
  final DocumentDto document;
  final List<GeneratedQuestionDto> questions;

  QuizGenerationResult({required this.document, required this.questions});
}

class QuizGenerationService {
  QuizGenerationService._();
  static final QuizGenerationService instance = QuizGenerationService._();

  Future<QuizGenerationResult> generateQuestionsFromFile({
    required String fileName,
    required Uint8List fileBytes,
    required String quizTitle,
    required int numberOfQuestions,
    required String difficulty,
  }) async {
    // 1. Nén zip — backend chỉ ký presigned URL cho application/zip,
    // PUT file thô sẽ bị S3 403 vì lệch chữ ký (xem DocumentApi.zipSingleFile).
    final zipped = DocumentApi.zipSingleFile(
      fileName: fileName,
      bytes: fileBytes,
    );

    // 2. Generate S3 Upload URL
    final presign = await DocumentApi.instance.generateUploadUrl(
      fileName: fileName,
      contentType: 'application/zip',
    );

    // 3. Upload file to S3
    await DocumentApi.instance.putToS3(
      uploadUrl: presign.uploadUrl,
      contentType: 'application/zip',
      bytes: zipped,
    );

    // 4. Create Document in backend (kèm tên gốc để hiển thị đẹp)
    final doc = await DocumentApi.instance.createFromS3Key(
      presign.s3Key,
      fileName: fileName,
    );

    // 5. Generate questions using AI API
    final questions = await AiApi.instance.generateQuestions(
      fileUrl: doc.presignedUrl,
      documentId: doc.id,
      quizTitle: quizTitle,
      numberOfQuestions: numberOfQuestions,
      difficulty: difficulty,
    );

    return QuizGenerationResult(document: doc, questions: questions);
  }

  /// Trả về quiz vừa tạo để caller điều hướng chơi ĐÚNG quiz đó
  /// (giống web: navigate library kèm targetQuizId sau khi publish).
  Future<QuizDto> saveGeneratedQuiz({
    required int documentId,
    required String quizTitle,
    required List<GeneratedQuestionDto> questions,
  }) async {
    // 1. Create Quiz in backend (status mặc định BE đặt là AI_Drafted)
    final quiz = await QuizApi.instance.createQuiz(
      documentId: documentId,
      title: quizTitle,
    );

    // 2. Loop and create questions in backend
    for (final q in questions) {
      await QuestionApi.instance.createQuestion(
        quizId: quiz.id,
        questionText: q.questionText,
        questionType: q.questionType,
        options: q.options
            .map((o) => {'optionText': o.optionText, 'isCorrect': o.isCorrect})
            .toList(),
      );
    }

    // 3. Update Quiz Status to Teacher_Approved (web hiển thị là "Đã duyệt")
    await QuizApi.instance.updateQuiz(
      quiz.id,
      title: quizTitle,
      status: 'Teacher_Approved',
    );

    return quiz;
  }
}
