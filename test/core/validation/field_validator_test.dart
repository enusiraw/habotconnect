import 'package:flutter_test/flutter_test.dart';
import 'package:habotconnect_lsa_verification/core/validation/field_validator.dart';
import 'package:habotconnect_lsa_verification/features/profile_verification/domain/models.dart';

void main() {
  group('FieldValidator', () {
    late FieldValidator validator;

    setUp(() {
      validator = FieldValidator();
    });

    group('LSA Validation', () {
      test('should pass with valid LSA fields', () {
        final request = LsaVerificationRequest(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PCC-2026-9901',
          predecessorId: 'PRED-9982-XYZ',
        );

        final result = validator.validateLsa(request);

        expect(result.isValid, isTrue);
        expect(result.fieldErrors, isEmpty);
      });

      test('should fail with empty lsa_id', () {
        final request = LsaVerificationRequest(
          lsaId: '',
          parentConsentCode: 'PCC-2026-9901',
          predecessorId: 'PRED-9982-XYZ',
        );

        final result = validator.validateLsa(request);

        expect(result.isValid, isFalse);
        expect(result.fieldErrors, contains('LSA ID is required'));
      });

      test('should fail with empty parent_consent_code', () {
        final request = LsaVerificationRequest(
          lsaId: 'LSA-7049',
          parentConsentCode: '',
          predecessorId: 'PRED-9982-XYZ',
        );

        final result = validator.validateLsa(request);

        expect(result.isValid, isFalse);
        expect(result.fieldErrors, contains('Parent consent code is required'));
      });
    });
  });
}