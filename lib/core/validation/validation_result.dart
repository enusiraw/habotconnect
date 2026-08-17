// Validation result model
class ValidationResult {
  final bool isValid;
  final String? reason;
  final List<String> fieldErrors;

  ValidationResult({
    required this.isValid,
    this.reason,
    this.fieldErrors = const [],
  });

  factory ValidationResult.success() {
    return ValidationResult(isValid: true);
  }

  factory ValidationResult.failure({String? reason, List<String> fieldErrors = const []}) {
    return ValidationResult(
      isValid: false,
      reason: reason,
      fieldErrors: fieldErrors,
    );
  }
}