import 'package:flutter_test/flutter_test.dart';
import 'package:habotconnect_lsa_verification/core/quarantine/quarantine_service.dart';
import 'package:habotconnect_lsa_verification/core/network/profile_verification_api.dart';
import 'package:habotconnect_lsa_verification/features/profile_verification/domain/models.dart';
import 'package:habotconnect_lsa_verification/features/profile_verification/domain/submission_controller.dart';
import 'package:habotconnect_lsa_verification/features/profile_verification/domain/errors.dart';

void main() {
  group('Submission Integration Tests', () {
    late SubmissionController controller;
    late InMemoryQuarantineService quarantineService;
    late MockProfileVerificationApi mockApi;

    setUp(() {
      quarantineService = InMemoryQuarantineService();
      mockApi = MockProfileVerificationApi();
      mockApi.disableSimulation(); // Disable simulation for normal tests
      controller = SubmissionController(
        quarantineService: quarantineService,
        apiClient: mockApi,
      );
    });

    tearDown(() {
      mockApi.resetCallCount();
    });

    test('Case 1: Valid submission should succeed', () async {
      final request = LsaVerificationRequest(
        lsaId: 'LSA-7049',
        parentConsentCode: 'PCC-2026-9901',
        predecessorId: 'PRED-9982-XYZ',
      );

      final result = await controller.submit(request);

      expect(result.isSuccess, isTrue);
      expect(result.data?.success, isTrue);
      expect(quarantineService.records.length, equals(0));
      expect(mockApi.callCount, equals(1)); // API was called
    });

    test('Case 2: Missing lineage should fail and quarantine', () async {
      final request = LsaVerificationRequest(
        lsaId: 'LSA-7049',
        parentConsentCode: 'PCC-2026-9901',
        predecessorId: null, // Missing lineage
      );

      final result = await controller.submit(request);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<LineageFailure>());
      expect(quarantineService.records.length, equals(1));
      expect(quarantineService.records.first.reason, contains('predecessor_id'));
      expect(mockApi.callCount, equals(0)); // API was NOT called
    });

    test('Case 3: Invalid required field should fail and quarantine', () async {
      final request = LsaVerificationRequest(
        lsaId: '', // Invalid - empty required field
        parentConsentCode: 'PCC-2026-9901',
        predecessorId: 'PRED-9982-XYZ',
      );

      final result = await controller.submit(request);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationFailure>());
      expect(quarantineService.records.length, equals(1));
      expect(quarantineService.records.first.reason, contains('Field validation'));
      expect(mockApi.callCount, equals(0)); // API was NOT called
    });

    test('Fail-closed: Compliance violation should block API call', () async {
      final request = LsaVerificationRequest(
        lsaId: '<script>alert("xss")</script>', // Malicious input
        parentConsentCode: 'PCC-2026-9901',
        predecessorId: 'PRED-9982-XYZ',
      );

      final result = await controller.submit(request);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ComplianceFailure>());
      expect(quarantineService.records.length, equals(1));
      // Data was quarantined, API was never called
      expect(quarantineService.records.first.reason, contains('Compliance'));
      expect(mockApi.callCount, equals(0)); // API was NOT called
    });

    test('Empty predecessor_id should fail lineage validation', () async {
      final request = LsaVerificationRequest(
        lsaId: 'LSA-7049',
        parentConsentCode: 'PCC-2026-9901',
        predecessorId: '', // Empty instead of null
      );

      final result = await controller.submit(request);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<LineageFailure>());
      expect(quarantineService.records.length, equals(1));
      expect(mockApi.callCount, equals(0)); // API was NOT called
    });

    test('Short predecessor_id should fail lineage validation', () async {
      final request = LsaVerificationRequest(
        lsaId: 'LSA-7049',
        parentConsentCode: 'PCC-2026-9901',
        predecessorId: 'short', // Too short
      );

      final result = await controller.submit(request);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<LineageFailure>());
      expect(quarantineService.records.length, equals(1));
      expect(mockApi.callCount, equals(0)); // API was NOT called
    });
  });
}