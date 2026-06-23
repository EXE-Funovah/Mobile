import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/data/api/ai_api.dart';
import 'package:mascoteach_mobile/data/api/document_api.dart';
import 'package:mascoteach_mobile/data/api/quiz_api.dart';
import 'package:mascoteach_mobile/data/api/question_api.dart';
import 'package:mascoteach_mobile/data/models/document.dart' as doc_model;
import 'package:mascoteach_mobile/data/models/quiz.dart';
import 'package:mascoteach_mobile/features/quiz/providers/quiz_generation_service.dart';

// Fake implementations for TDD
class FakeDocumentApi implements DocumentApi {
  bool generateUploadUrlCalled = false;
  bool putToS3Called = false;
  bool createFromS3KeyCalled = false;
  String? presignContentType;
  String? putContentType;
  Uint8List? putBytes;

  @override
  Future<doc_model.PresignResponse> generateUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    generateUploadUrlCalled = true;
    presignContentType = contentType;
    return const doc_model.PresignResponse(
      uploadUrl: 'https://s3.amazonaws.com/upload-presigned',
      s3Key: 'uploads/test-file.pdf',
    );
  }

  @override
  Future<void> putToS3({
    required String uploadUrl,
    required String contentType,
    Uint8List? bytes,
    File? file,
  }) async {
    putToS3Called = true;
    putContentType = contentType;
    putBytes = bytes;
  }

  @override
  Future<doc_model.DocumentDto> createFromS3Key(
    String s3Key, {
    String? fileName,
  }) async {
    createFromS3KeyCalled = true;
    return doc_model.DocumentDto(
      id: 42,
      s3Key: s3Key,
      presignedUrl: 'https://s3.amazonaws.com/test-file.pdf',
      fileName: fileName,
      uploadedAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAiApi implements AiApi {
  bool generateQuestionsCalled = false;
  String? passedFileUrl;
  int? passedDocumentId;
  String? passedQuizTitle;
  int? passedNumberOfQuestions;
  String? passedDifficulty;

  @override
  Future<List<GeneratedQuestionDto>> generateQuestions({
    required String fileUrl,
    required int documentId,
    required String quizTitle,
    required int numberOfQuestions,
    required String difficulty,
  }) async {
    generateQuestionsCalled = true;
    passedFileUrl = fileUrl;
    passedDocumentId = documentId;
    passedQuizTitle = quizTitle;
    passedNumberOfQuestions = numberOfQuestions;
    passedDifficulty = difficulty;

    return [
      const GeneratedQuestionDto(
        questionText: 'What is mitochondria?',
        questionType: 'MultipleChoice',
        options: [
          GeneratedOptionDto(optionText: 'Powerhouse', isCorrect: true),
          GeneratedOptionDto(optionText: 'Brain', isCorrect: false),
        ],
      ),
    ];
  }
}

class FakeQuizApi implements QuizApi {
  bool createQuizCalled = false;
  bool updateQuizCalled = false;
  int? createdDocumentId;
  String? createdTitle;
  int? updatedQuizId;
  String? updatedTitle;
  String? updatedStatus;

  @override
  Future<QuizDto> createQuiz({
    required int documentId,
    required String title,
  }) async {
    createQuizCalled = true;
    createdDocumentId = documentId;
    createdTitle = title;
    return QuizDto(
      id: 99,
      documentId: documentId,
      title: title,
      status: 'AI_Drafted',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateQuiz(
    int id, {
    required String title,
    required String status,
  }) async {
    updateQuizCalled = true;
    updatedQuizId = id;
    updatedTitle = title;
    updatedStatus = status;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeQuestionApi implements QuestionApi {
  bool createQuestionCalled = false;
  List<Map<String, dynamic>> createdQuestions = [];

  @override
  Future<QuestionDto> createQuestion({
    required int quizId,
    required String questionText,
    required String questionType,
    required List<Map<String, dynamic>> options,
  }) async {
    createQuestionCalled = true;
    createdQuestions.add({
      'quizId': quizId,
      'questionText': questionText,
      'questionType': questionType,
      'options': options,
    });
    return QuestionDto(
      id: 100 + createdQuestions.length,
      quizId: quizId,
      questionText: questionText,
      questionType: questionType,
      options: options
          .map(
            (o) => OptionDto(
              id: 500,
              questionId: quizId,
              optionText: o['optionText'] ?? o['OptionText'] ?? '',
              isCorrect: o['isCorrect'] ?? o['IsCorrect'] == true,
            ),
          )
          .toList(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeDocumentApi fakeDocApi;
  late FakeAiApi fakeAiApi;
  late FakeQuizApi fakeQuizApi;
  late FakeQuestionApi fakeQuestionApi;

  setUp(() {
    fakeDocApi = FakeDocumentApi();
    fakeAiApi = FakeAiApi();
    fakeQuizApi = FakeQuizApi();
    fakeQuestionApi = FakeQuestionApi();

    // Inject Fakes into singleton instance fields
    DocumentApi.instance = fakeDocApi;
    AiApi.instance = fakeAiApi;
    QuizApi.instance = fakeQuizApi;
    QuestionApi.instance = fakeQuestionApi;
  });

  group('QuizGenerationService Tests', () {
    test(
      'generateQuestionsFromFile runs file upload and calls AI service',
      () async {
        final service = QuizGenerationService.instance;
        final result = await service.generateQuestionsFromFile(
          fileName: 'biology.pdf',
          fileBytes: Uint8List.fromList([1, 2, 3]),
          quizTitle: 'Biology Cell Quiz',
          numberOfQuestions: 5,
          difficulty: 'Vừa',
        );

        // Verify Document API was called
        expect(fakeDocApi.generateUploadUrlCalled, isTrue);
        expect(fakeDocApi.putToS3Called, isTrue);
        expect(fakeDocApi.createFromS3KeyCalled, isTrue);

        // Backend chỉ ký presigned URL cho application/zip — file phải được
        // nén zip trước khi PUT, không được upload bytes thô.
        expect(fakeDocApi.presignContentType, 'application/zip');
        expect(fakeDocApi.putContentType, 'application/zip');
        expect(fakeDocApi.putBytes, isNotNull);
        // Zip luôn bắt đầu bằng magic bytes "PK" (0x50 0x4B)
        expect(fakeDocApi.putBytes!.length, greaterThan(2));
        expect(fakeDocApi.putBytes![0], 0x50);
        expect(fakeDocApi.putBytes![1], 0x4B);

        // Verify AI API was called
        expect(fakeAiApi.generateQuestionsCalled, isTrue);
        expect(
          fakeAiApi.passedFileUrl,
          'https://s3.amazonaws.com/test-file.pdf',
        );
        expect(fakeAiApi.passedDocumentId, 42);
        expect(fakeAiApi.passedQuizTitle, 'Biology Cell Quiz');
        expect(fakeAiApi.passedNumberOfQuestions, 5);
        expect(fakeAiApi.passedDifficulty, 'Vừa');

        // Verify returned objects
        expect(result.document.id, 42);
        expect(result.questions, hasLength(1));
        expect(result.questions.first.questionText, 'What is mitochondria?');
      },
    );

    test(
      'saveGeneratedQuiz creates Quiz, inserts Questions, and updates Status',
      () async {
        final service = QuizGenerationService.instance;

        final previewQuestions = [
          const GeneratedQuestionDto(
            questionText: 'Is cell membrane semi-permeable?',
            questionType: 'MultipleChoice',
            options: [
              GeneratedOptionDto(optionText: 'Yes', isCorrect: true),
              GeneratedOptionDto(optionText: 'No', isCorrect: false),
            ],
          ),
        ];

        final created = await service.saveGeneratedQuiz(
          documentId: 42,
          quizTitle: 'Biology Cell Quiz Updated',
          questions: previewQuestions,
        );

        // Trả về quiz vừa tạo để caller chơi đúng quiz đó (như web targetQuizId)
        expect(created.id, 99);

        // Verify Quiz API create was called
        expect(fakeQuizApi.createQuizCalled, isTrue);
        expect(fakeQuizApi.createdDocumentId, 42);
        expect(fakeQuizApi.createdTitle, 'Biology Cell Quiz Updated');

        // Verify Question API create was called
        expect(fakeQuestionApi.createQuestionCalled, isTrue);
        expect(fakeQuestionApi.createdQuestions, hasLength(1));
        expect(fakeQuestionApi.createdQuestions.first['quizId'], 99);
        expect(
          fakeQuestionApi.createdQuestions.first['questionText'],
          'Is cell membrane semi-permeable?',
        );

        // Verify Quiz API update was called to approve
        expect(fakeQuizApi.updateQuizCalled, isTrue);
        expect(fakeQuizApi.updatedQuizId, 99);
        expect(fakeQuizApi.updatedTitle, 'Biology Cell Quiz Updated');
        expect(fakeQuizApi.updatedStatus, 'Teacher_Approved');
      },
    );
  });
}
