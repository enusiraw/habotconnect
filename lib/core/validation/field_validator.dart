import 'validation_result.dart';
import '../../../features/profile_verification/domain/models.dart';

// Validates required fields in the LSA verification request
class FieldValidator {
  /// Validate LSA-specific fields
  ValidationResult validateLsa(LsaVerificationRequest request) {
    final errors = <String>[];

    // Validate lsa_id
    if (request.lsaId.trim().isEmpty) {
      errors.add('LSA ID is required');
    }

    // Validate parent_consent_code
    if (request.parentConsentCode.trim().isEmpty) {
      errors.add('Parent consent code is required');
    }

    if (errors.isEmpty) {
      return ValidationResult.success();
    }

    return ValidationResult.failure(
      reason: 'Field validation failed',
      fieldErrors: errors,
    );
  }
}
