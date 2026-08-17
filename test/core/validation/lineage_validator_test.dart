import 'package:flutter_test/flutter_test.dart';
import 'package:habotconnect_lsa_verification/core/validation/lineage_validator.dart';
import 'package:habotconnect_lsa_verification/features/profile_verification/domain/models.dart';

void main() {
  group('LineageValidator', () {
    late LineageValidator validator;

    setUp(() {
      validator = LineageValidator();
    });

    group('LSA Validation', () {
      test('should pass with valid LSA predecessor_id', () {
        final request = LsaVerificationRequest(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PCC-2026-9901',
          predecessorId: 'PRED-9982-XYZ',
        );

        final result = validator.validateLsa(request);

        expect(result.isValid, isTrue);
        expect(result.reason, isNull);
        expect(result.fieldErrors, isEmpty);
      });

      test('should fail with null LSA predecessor_id', () {
        final request = LsaVerificationRequest(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PCC-2026-9901',
          predecessorId: null,
        );

        final result = validator.validateLsa(request);

        expect(result.isValid, isFalse);
        expect(result.reason, contains('predecessor_id is null'));
        expect(result.fieldErrors, isNotEmpty);
      });

      test('should fail with empty LSA predecessor_id', () {
        final request = LsaVerificationRequest(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PCC-2026-9901',
          predecessorId: '',
        );

        final result = validator.validateLsa(request);

        expect(result.isValid, isFalse);
        expect(result.reason, contains('predecessor_id is empty'));
        expect(result.fieldErrors, isNotEmpty);
      });
    });
  });
}