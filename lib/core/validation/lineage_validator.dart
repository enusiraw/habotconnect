import 'validation_result.dart';
import '../../../features/profile_verification/domain/models.dart';

class LineageValidator {
  /// Validate LSA-specific lineage
  ValidationResult validateLsa(LsaVerificationRequest request) {
    final predecessorId = request.predecessorId;

    // Check if predecessor_id is null
    if (predecessorId == null) {
      return ValidationResult.failure(
        reason: 'Data lineage validation failed: predecessor_id is null',
        fieldErrors: ['predecessorId is required for data lineage tracking'],
      );
    }

    // Check if predecessor_id is empty
    if (predecessorId.trim().isEmpty) {
      return ValidationResult.failure(
        reason: 'Data lineage validation failed: predecessor_id is empty',
        fieldErrors: ['predecessorId cannot be empty'],
      );
    }

    // Check if predecessor_id is too short (basic validation)
    if (predecessorId.trim().length < 8) {
      return ValidationResult.failure(
        reason: 'Data lineage validation failed: predecessor_id is invalid',
        fieldErrors: ['predecessorId must be at least 8 characters'],
      );
    }

    return ValidationResult.success();
  }
}
