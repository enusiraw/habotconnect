import 'dart:async';
import 'friction_event.dart';

class FrictionTracker {
  static const Duration _stallThreshold = Duration(seconds: 5);
  
  final Map<String, DateTime> _lastInteractionTimes = {};
  final Map<String, Timer?> _activeTimers = {};
  final List<FrictionEvent> _events = [];
  
  final void Function(FrictionEvent) onFrictionEvent;

  FrictionTracker({required this.onFrictionEvent});

  // Record user interaction with a field

  void recordInteraction(String fieldId) {
    _lastInteractionTimes[fieldId] = DateTime.now();
    
    // Cancel existing timer if any
    _activeTimers[fieldId]?.cancel();
    
    // Start new timer
    _activeTimers[fieldId] = Timer(_stallThreshold, () {
      _handleStall(fieldId);
    });
  }

 
  void startTracking(String fieldId) {
    _lastInteractionTimes[fieldId] = DateTime.now();
    
    // Cancel existing timer if any
    _activeTimers[fieldId]?.cancel();
    
    // Start new timer
    _activeTimers[fieldId] = Timer(_stallThreshold, () {
      _handleStall(fieldId);
    });
  }

  /// Handle stall detection
  void _handleStall(String fieldId) {
    final lastInteraction = _lastInteractionTimes[fieldId];
    if (lastInteraction == null) return;

    final duration = DateTime.now().difference(lastInteraction);
    final timestamp = DateTime.now().toUtc();
    
    final event = FrictionEvent(
      eventId: _generateEventId(),
      fieldId: fieldId,
      duration: duration,
      timestamp: timestamp,
      type: FrictionEventType.fieldStall,
    );

    _events.add(event);
    onFrictionEvent(event);
    
    // Format: [UI_FRICTION_LOG] Timestamp: 2026-08-07T11:31:05Z | Field: parent_consent_code | Hesitation Duration: 5.2s
    final durationSeconds = duration.inMilliseconds / 1000.0;
    print('[UI_FRICTION_LOG] Timestamp: ${timestamp.toIso8601String()} | Field: $fieldId | Hesitation Duration: ${durationSeconds}s');
  }

  /// Clear all timers and state
  void dispose() {
    for (final timer in _activeTimers.values) {
      timer?.cancel();
    }
    _activeTimers.clear();
    _lastInteractionTimes.clear();
  }

  /// Get all recorded friction events
  List<FrictionEvent> get events => List.unmodifiable(_events);

  /// Clear all events
  void clearEvents() {
    _events.clear();
  }

  String _generateEventId() {
    return 'evt_${DateTime.now().millisecondsSinceEpoch}';
  }
}