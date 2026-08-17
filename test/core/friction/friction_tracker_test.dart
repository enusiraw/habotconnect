import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:habotconnect_lsa_verification/core/friction/friction_tracker.dart';
import 'package:habotconnect_lsa_verification/core/friction/friction_event.dart';

void main() {
  group('FrictionTracker', () {
    late FrictionTracker tracker;
    late List<FrictionEvent> capturedEvents;

    setUp(() {
      capturedEvents = [];
      tracker = FrictionTracker(
        onFrictionEvent: (event) => capturedEvents.add(event),
      );
    });

    tearDown(() {
      tracker.dispose();
    });

    test('should not record friction event for interaction under 5 seconds', () {
      fakeAsync((async) {
        tracker.recordInteraction('field1');
        
        // Elapse 4 seconds (under threshold)
        async.elapse(const Duration(seconds: 4));
        
        expect(capturedEvents, isEmpty);
      });
    });

    test('should record friction event for stall over 5 seconds', () {
      fakeAsync((async) {
        tracker.recordInteraction('field1');
        
        // Elapse 6 seconds (over threshold)
        async.elapse(const Duration(seconds: 6));
        
        expect(capturedEvents.length, equals(1));
        expect(capturedEvents[0].fieldId, equals('field1'));
        expect(capturedEvents[0].type, equals(FrictionEventType.fieldStall));
      });
    });

    test('should reset timer on new interaction', () {
      fakeAsync((async) {
        tracker.recordInteraction('field1');
        
        // Elapse 3 seconds
        async.elapse(const Duration(seconds: 3));
        
        // New interaction resets timer
        tracker.recordInteraction('field1');
        
        // Elapse another 3 seconds (total 6, but timer reset at 3)
        async.elapse(const Duration(seconds: 3));
        
        expect(capturedEvents, isEmpty);
      });
    });

    test('should record friction event after reset if stall occurs', () {
      fakeAsync((async) {
        tracker.recordInteraction('field1');
        async.elapse(const Duration(seconds: 2));
        
        tracker.recordInteraction('field1');
        async.elapse(const Duration(seconds: 6));
        
        expect(capturedEvents.length, equals(1));
        expect(capturedEvents[0].fieldId, equals('field1'));
      });
    });

    test('should track multiple fields independently', () {
      fakeAsync((async) {
        tracker.recordInteraction('field1');
        tracker.recordInteraction('field2');
        
        async.elapse(const Duration(seconds: 6));
        
        expect(capturedEvents.length, equals(2));
        expect(capturedEvents.any((e) => e.fieldId == 'field1'), isTrue);
        expect(capturedEvents.any((e) => e.fieldId == 'field2'), isTrue);
      });
    });
  });
}