import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/document.dart';
import 'dio_client.dart';

class DocumentApi {
  DocumentApi._();
  static DocumentApi instance = DocumentApi._();

  final Dio _dio = DioClient.instance.dio;

  /// GET /api/Document/me — tài liệu của user hiện tại.
  Future<List<DocumentDto>> getMine() async {
    final res = await _dio.get(ApiConstants.documentsMe);
    _ensureOk(res);
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => DocumentDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  /// GET /api/Document/{id}
  Future<DocumentDto> getById(int id) async {
    final res = await _dio.get('${ApiConstants.documents}/$id');
    _ensureOk(res);
    return DocumentDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// POST /api/Document/generate-upload-url — xin URL S3 để PUT file lên.
  Future<PresignResponse> generateUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    final res = await _dio.post(
      ApiConstants.documentsPresign,
      data: {'fileName': fileName, 'contentType': contentType},
    );
    _ensureOk(res);
    return PresignResponse.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// POST /api/Document — lưu metadata sau khi đã PUT file lên S3.
  /// `fileName` = tên file gốc (vd. "sinh-hoc.pdf") để hiển thị đẹp.
  Future<DocumentDto> createFromS3Key(String s3Key, {String? fileName}) async {
    final res = await _dio.post(
      ApiConstants.documents,
      data: {
        's3Key': s3Key,
        if (fileName != null && fileName.isNotEmpty) 'fileName': fileName,
      },
    );
    _ensureOk(res);
    return DocumentDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Nén 1 file thành zip in-memory.
  ///
  /// Backend ký presigned URL CHỈ cho `application/zip` (S3Service ép key
  /// `.zip` + ContentType zip) — PUT file thô sẽ bị S3 403 vì lệch chữ ký.
  /// Web frontend cũng nén như vậy; AI service đọc zip rồi giải nén.
  static Uint8List zipSingleFile({
    required String fileName,
    required Uint8List bytes,
  }) {
    final archive = Archive()
      ..addFile(ArchiveFile(fileName, bytes.length, bytes));
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  /// DELETE /api/Document/{id}
  Future<void> delete(int id) async {
    final res = await _dio.delete('${ApiConstants.documents}/$id');
    _ensureOk(res);
  }

  /// PUT file thẳng lên S3 bằng presigned URL.
  ///
  /// S3 từ chối request có Authorization header dư, nên dùng Dio rỗng.
  Future<void> putToS3({
    required String uploadUrl,
    required String contentType,
    Uint8List? bytes,
    File? file,
  }) async {
    assert(bytes != null || file != null, 'Cần bytes hoặc file');
    final raw = Dio(
      BaseOptions(
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        headers: {'Content-Type': contentType},
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    final data = bytes ?? await file!.readAsBytes();
    final res = await raw.put(
      uploadUrl,
      data: Stream.fromIterable([data]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          Headers.contentLengthHeader: data.length,
        },
      ),
    );
    if (res.statusCode == null || res.statusCode! >= 300) {
      throw Exception('Upload S3 thất bại: ${res.statusCode}');
    }
  }

  void _ensureOk(Response res) {
    if (res.statusCode == null || res.statusCode! >= 400) {
      final d = res.data;
      String msg = 'Lỗi ${res.statusCode}';
      if (d is Map) {
        msg = (d['message'] ?? d['Message'] ?? d['error'] ?? msg).toString();
      } else if (d is String && d.isNotEmpty) {
        msg = d;
      }
      throw Exception(msg);
    }
  }
}
