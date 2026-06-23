/// Document entity trả về từ backend (mapping DocumentResponse C#).
class DocumentDto {
  final int id;
  final String s3Key;
  final String presignedUrl;
  final String? fileName; // tên file gốc do backend lưu (file_name)
  final DateTime? uploadedAt;
  final bool isDeleted;

  const DocumentDto({
    required this.id,
    required this.s3Key,
    required this.presignedUrl,
    this.fileName,
    this.uploadedAt,
    this.isDeleted = false,
  });

  factory DocumentDto.fromJson(Map<String, dynamic> json) {
    return DocumentDto(
      id: _asInt(json['id'] ?? json['Id']) ?? 0,
      s3Key: (json['s3Key'] ?? json['S3Key'] ?? '').toString(),
      presignedUrl: (json['presignedUrl'] ?? json['PresignedUrl'] ?? '')
          .toString(),
      fileName: (json['fileName'] ?? json['FileName'])?.toString(),
      uploadedAt: _asDate(json['uploadedAt'] ?? json['UploadedAt']),
      isDeleted: (json['isDeleted'] ?? json['IsDeleted']) == true,
    );
  }

  /// Tên file để hiển thị: ưu tiên `fileName` backend lưu; fallback cắt
  /// UUID prefix khỏi key; cuối cùng `Tài liệu #id` (key dạng uuid.zip).
  String get displayName {
    if (fileName != null && fileName!.trim().isNotEmpty) {
      return fileName!.trim();
    }
    final last = s3Key.split('/').last;
    final stripped = last.replaceFirst(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-?',
        caseSensitive: false,
      ),
      '',
    );
    if (stripped.isEmpty || RegExp(r'^\.[a-zA-Z0-9]+$').hasMatch(stripped)) {
      return 'Tài liệu #$id';
    }
    return stripped;
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _asDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}

/// Response khi xin presigned upload URL.
class PresignResponse {
  final String uploadUrl;
  final String s3Key;
  final String? fileUrl;

  const PresignResponse({
    required this.uploadUrl,
    required this.s3Key,
    this.fileUrl,
  });

  factory PresignResponse.fromJson(Map<String, dynamic> json) {
    return PresignResponse(
      uploadUrl: (json['uploadUrl'] ?? json['UploadUrl'] ?? '').toString(),
      s3Key: (json['s3Key'] ?? json['S3Key'] ?? '').toString(),
      fileUrl: (json['fileUrl'] ?? json['FileUrl'])?.toString(),
    );
  }
}
