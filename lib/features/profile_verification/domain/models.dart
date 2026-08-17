// LSA verification request data
class LsaVerificationRequest {
  final String lsaId;
  final String parentConsentCode;
  final String? predecessorId;
  final DateTime timestampUtc;

  LsaVerificationRequest({
    required this.lsaId,
    required this.parentConsentCode,
    this.predecessorId,
    DateTime? timestampUtc,
  }) : timestampUtc = timestampUtc ?? DateTime.now().toUtc();

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'predecessor_id': predecessorId,
      'lsa_id': lsaId,
      'parent_consent_code': parentConsentCode,
      'timestamp_utc': timestampUtc.toIso8601String(),
    };
  }

  // Create copy with modified fields
  LsaVerificationRequest copyWith({
    String? lsaId,
    String? parentConsentCode,
    String? predecessorId,
    DateTime? timestampUtc,
  }) {
    return LsaVerificationRequest(
      lsaId: lsaId ?? this.lsaId,
      parentConsentCode: parentConsentCode ?? this.parentConsentCode,
      predecessorId: predecessorId ?? this.predecessorId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
    );
  }
}

// API submission request with metadata
class SubmissionRequest {
  final LsaVerificationRequest data;
  final String traceId;
  final String logicHash;

  SubmissionRequest({
    required this.data,
    required this.traceId,
    required this.logicHash,
  });

  // Convert to map for API submission
  Map<String, dynamic> toMap() {
    return {
      'data': data.toMap(),
      'metadata': {
        'traceId': traceId,
        'logicHash': logicHash,
      },
    };
  }
}

// API response
class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final int? statusCode;
  final String? status;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.status,
  });

  factory ApiResponse.success({String? message, Map<String, dynamic>? data}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
      status: 'success',
    );
  }

  factory ApiResponse.failure({required String message, int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode ?? 400,
      status: null,
    );
  }

  factory ApiResponse.quarantineFailure() {
    return ApiResponse(
      success: false,
      message: 'Data Quarantined – Compliance Failure',
      statusCode: 500,
      status: null,
    );
  }
}