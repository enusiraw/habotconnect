import '../../../core/crypto/uuid_generator.dart';
import '../../../core/crypto/sha256_generator.dart';

import '../../../core/validation/field_validator.dart';
import '../../../core/validation/lineage_validator.dart';
import '../../../core/validation/compliance_validator.dart';
import '../../../core/quarantine/quarantine_service.dart';

import '../../../core/network/profile_verification_api.dart';
import 'models.dart';
import 'errors.dart';


class SubmissionController {
  final FieldValidator _fieldValidator;
  final LineageValidator _lineageValidator;
  final ComplianceValidator _complianceValidator;
  final QuarantineService _quarantineService;
  final ProfileVerificationApi _apiClient;

  SubmissionController({
    FieldValidator? fieldValidator,
    LineageValidator? lineageValidator,
    ComplianceValidator? complianceValidator,
    QuarantineService? quarantineService,
    ProfileVerificationApi? apiClient,
  })  : _fieldValidator = fieldValidator ?? FieldValidator(),
        _lineageValidator = lineageValidator ?? LineageValidator(),
        _complianceValidator = complianceValidator ?? ComplianceValidator(),
        _quarantineService = quarantineService ?? InMemoryQuarantineService(),
        _apiClient = apiClient ?? MockProfileVerificationApi();


  Future<Result<ApiResponse>> submit(LsaVerificationRequest request) async {
    print('VALIDATION: Starting submission validation pipeline');

    // 1: Field Validation
    print('VALIDATION: Step 1 - Field validation');
    final fieldValidation = _fieldValidator.validateLsa(request);
    if (!fieldValidation.isValid) {
      print('VALIDATION: FAILED - Field validation failed');
      await _quarantineService.quarantineLsa(
        request: request,
        reason: fieldValidation.reason ?? 'Field validation failed',
      );
      return Result.failure(ValidationFailure(
        fieldValidation.reason ?? 'Field validation failed',
        fieldErrors: fieldValidation.fieldErrors,
      ));
    }
    print('VALIDATION: PASSED - Field validation');

    // 2: Lineage Validation (predecessor_id)
    print('VALIDATION: Step 2 - Lineage validation');
    final lineageValidation = _lineageValidator.validateLsa(request);
    if (!lineageValidation.isValid) {
      print('VALIDATION: FAILED - Lineage validation failed');
      await _quarantineService.quarantineLsa(
        request: request,
        reason: lineageValidation.reason ?? 'Lineage validation failed',
      );
      return Result.failure(LineageFailure(
        lineageValidation.reason ?? 'Lineage validation failed',
        details: lineageValidation.fieldErrors.join(', '),
      ));
    }
    print('VALIDATION: PASSED - Lineage validation (predecessor_id: ${request.predecessorId})');

    // 3: Compliance Validation
    print('VALIDATION: Step 3 - Compliance validation');
    final complianceValidation = _complianceValidator.validateLsa(request);
    if (!complianceValidation.isValid) {
      print('VALIDATION: FAILED - Compliance validation failed');
      await _quarantineService.quarantineLsa(
        request: request,
        reason: complianceValidation.reason ?? 'Compliance validation failed',
      );
      return Result.failure(ComplianceFailure(
        complianceValidation.reason ?? 'Compliance validation failed',
        details: complianceValidation.fieldErrors.join(', '),
      ));
    }
    print('VALIDATION: PASSED - Compliance validation');

    // 4: Metadata Generation
    print('METADATA: Generating trace_id and logic_hash');
    final traceId = UuidGenerator.generate();
    print('METADATA: trace_id generated: $traceId');
    
    // Generate logic_hash from canonical representation of request data
    final logicHash = Sha256Generator.generateFromMap(request.toMap());
    print('METADATA: logic_hash generated: $logicHash');

    // Create submission request with metadata
    final submissionRequest = SubmissionRequest(
      data: request,
      traceId: traceId,
      logicHash: logicHash,
    );

    // 5: API Submission
    print('API: Submitting to API');
    try {
      final response = await _apiClient.submitLsa(submissionRequest);
      
      if (response.success) {
        print('API: Submission successful');
        return Result.success(response);
      } else {
        print('API: Submission failed - ${response.message}');
        return Result.failure(ServerFailure(
          response.message ?? 'Server error',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      print('API: Network error - $e');
      return Result.failure(NetworkFailure(
        'Network error occurred',
        details: e.toString(),
      ));
    }
  }
}