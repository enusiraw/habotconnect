import 'validation_result.dart';
import '../../../features/profile_verification/domain/models.dart';

class ComplianceValidator {
  // Validate LSA-specific compliance requirements
  ValidationResult validateLsa(LsaVerificationRequest request) {
    final errors = <String>[];

    // Check for potential SQL injection patterns in text fields
    if (_containsSqlPattern(request.lsaId)) {
      errors.add('LSA ID contains invalid characters');
    }
    if (_containsSqlPattern(request.parentConsentCode)) {
      errors.add('Parent consent code contains invalid characters');
    }

    // Check for script injection patterns
    if (_containsScriptPattern(request.lsaId)) {
      errors.add('LSA ID contains script patterns');
    }
    if (_containsScriptPattern(request.parentConsentCode)) {
      errors.add('Parent consent code contains script patterns');
    }

    // Validate that no field contains null bytes or other control characters
    if (_containsControlCharacters(request.lsaId)) {
      errors.add('LSA ID contains invalid control characters');
    }
    if (_containsControlCharacters(request.parentConsentCode)) {
      errors.add('Parent consent code contains invalid control characters');
    }

    if (errors.isEmpty) {
      return ValidationResult.success();
    }

    return ValidationResult.failure(
      reason: 'Compliance validation failed: security requirements not met',
      fieldErrors: errors,
    );
  }

  bool _containsSqlPattern(String input) {
    final sqlPatterns = [
      RegExp(r"('|('')|;|\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE){0,1}|INSERT( +INTO){0,1}|MERGE|SELECT|UPDATE|UNION( +ALL){0,1})\b)", caseSensitive: false),
    ];
    return sqlPatterns.any((pattern) => pattern.hasMatch(input));
  }

  bool _containsScriptPattern(String input) {
    final scriptPatterns = [
      RegExp(r'<script.*?>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
    ];
    return scriptPatterns.any((pattern) => pattern.hasMatch(input));
  }

  bool _containsControlCharacters(String input) {
    // Allow common whitespace but reject other control characters
    final controlCharPattern = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');
    return controlCharPattern.hasMatch(input);
  }
}
