/// Document entity trả về từ backend (mapping DocumentResponse C#).
class DocumentDto {
  final int id;
  final String s3Key;
  final String presignedUrl;
  final DateTime? uploadedAt;
  final bool isDeleted;

  const DocumentDto({
    required this.id,
    required this.s3Key,
    required this.presignedUrl,
    this.uploadedAt,
    this.isDeleted = false,
  });

  factory DocumentDto.fromJson(Map<String, dynamic> json) {
    return DocumentDto(
      id: _asInt(json['id'] ?? json['Id']) ?? 0,
      s3Key: (json['s3Key'] ?? json['S3Key'] ?? '').toString(),
      presignedUrl: (json['presignedUrl'] ?? json['PresignedUrl'] ?? '')
          .toString(),
      uploadedAt: _asDate(json['uploadedAt'] ?? json['UploadedAt']),
      isDeleted: (json['isDeleted'] ?? json['IsDeleted']) == true,
    );
  }

  /// Tên file để hiển thị: ưu tiên cắt UUID prefix khỏi key (theo format mới
  /// `{uuid}-{originalName.ext}`), fallback last segment, fallback `Tài liệu #id`.
  String get displayName {
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
