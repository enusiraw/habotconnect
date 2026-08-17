import '../../../features/profile_verification/domain/models.dart';


abstract class QuarantineService {
  Future<void> quarantineLsa({
    required LsaVerificationRequest request,
    required String reason,
    String? traceId,
  });
}


class InMemoryQuarantineService implements QuarantineService {
  final List<QuarantineRecord> _records = [];

  List<QuarantineRecord> get records => List.unmodifiable(_records);

  @override
  Future<void> quarantineLsa({
    required LsaVerificationRequest request,
    required String reason,
    String? traceId,
  }) async {
    final record = QuarantineRecord(
      timestamp: DateTime.now(),
      reason: reason,
      traceId: traceId,
      // Only log safe metadata, not sensitive data
      safeMetadata: {
        'hasPredecessorId': request.predecessorId != null,
        'timestampUtc': request.timestampUtc.toIso8601String(),
        'fieldCount': 3, // lsaId, parentConsentCode, predecessorId
      },
    );

    _records.add(record);
    
    // In production
    print('QUARANTINE: Data quarantined - $reason');
    print('QUARANTINE: Trace ID: ${traceId ?? "N/A"}');
    print('QUARANTINE: Safe metadata: ${record.safeMetadata}');
  }

  // Clear all quarantine records 
  void clear() {
    _records.clear();
  }
}

// Quarantine record containing safe metadata only
class QuarantineRecord {
  final DateTime timestamp;
  final String reason;
  final String? traceId;
  final Map<String, dynamic> safeMetadata;

  QuarantineRecord({
    required this.timestamp,
    required this.reason,
    this.traceId,
    required this.safeMetadata,
  });

  @override
  String toString() {
    return 'QuarantineRecord(timestamp: $timestamp, reason: $reason, traceId: $traceId, safeMetadata: $safeMetadata)';
  }
}
