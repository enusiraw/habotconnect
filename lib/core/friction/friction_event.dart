// Friction event model for tracking user stalls
class FrictionEvent {
  final String eventId;
  final String fieldId;
  final Duration duration;
  final DateTime timestamp;
  final FrictionEventType type;

  FrictionEvent({
    required this.eventId,
    required this.fieldId,
    required this.duration,
    required this.timestamp,
    required this.type,
  });

  @override
  String toString() {
   
    final utcTimestamp = timestamp.toUtc().toIso8601String();
    final durationSeconds = duration.inSeconds + (duration.inMilliseconds % 1000) / 1000.0;
    
    return '''[UI_FRICTION_LOG]
Timestamp: $utcTimestamp
Field: $fieldId
Hesitation Duration: ${durationSeconds}s''';
  }
}

enum FrictionEventType {
  fieldStall,
  formAbandonment,
  hesitation,
}