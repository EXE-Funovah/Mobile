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
    required String contentType,
    required Uint8List fileBytes,
    required String quizTitle,
    required int numberOfQuestions,
    required String difficulty,
  }) async {
    // 1. Generate S3 Upload URL
    final presign = await DocumentApi.instance.generateUploadUrl(
      fileName: fileName,
      contentType: contentType,
    );

    // 2. Upload file to S3
    await DocumentApi.instance.putToS3(
      uploadUrl: presign.uploadUrl,
      contentType: contentType,
      bytes: fileBytes,
    );

    // 3. Create Document in backend
    final doc = await DocumentApi.instance.createFromS3Key(presign.s3Key);

    // 4. Generate questions using AI API
    final questions = await AiApi.instance.generateQuestions(
      fileUrl: doc.presignedUrl,
      documentId: doc.id,
      quizTitle: quizTitle,
      numberOfQuestions: numberOfQuestions,
      difficulty: difficulty,
    );

    return QuizGenerationResult(document: doc, questions: questions);
  }

  Future<void> saveGeneratedQuiz({
    required int documentId,
    required String quizTitle,
    required List<GeneratedQuestionDto> questions,
  }) async {
    // 1. Create Quiz in backend
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

    // 3. Update Quiz Status to Teacher_Approved
    await QuizApi.instance.updateQuiz(
      quiz.id,
      title: quizTitle,
      status: 'Teacher_Approved',
    );
  }
}
