import '../../features/profile_verification/domain/models.dart';


abstract class ProfileVerificationApi {
  Future<ApiResponse> submit(SubmissionRequest request);
  Future<ApiResponse> submitLsa(SubmissionRequest request);
}


class MockProfileVerificationApi implements ProfileVerificationApi {
  int callCount = 0; // Track call count for testing
  bool simulateNullResponse = false; // For Case 3 
  bool simulateHttp500 = true; // For Case 3 
  
  @override
  Future<ApiResponse> submit(SubmissionRequest request) async {
    callCount++; // Increment call count
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate required metadata headers
    if (request.traceId.isEmpty) {
      return ApiResponse.failure(
        message: 'Missing trace_id metadata header',
        statusCode: 400,
      );
    }

    if (request.logicHash.isEmpty) {
      return ApiResponse.failure(
        message: 'Missing logic_hash metadata header',
        statusCode: 400,
      );
    }

    // Log the submission 
    print('API_REQUEST: Submitting profile verification');
    print('API_REQUEST: trace_id: ${request.traceId}');
    print('API_REQUEST: logic_hash: ${request.logicHash}');
    print('API_REQUEST: predecessor_id: ${request.data.predecessorId}');

    // Simulate successful submission
    return ApiResponse.success(
      message: 'Profile verification submitted successfully',
      data: {
        'submissionId': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'estimatedProcessingTime': '2-3 business days',
      },
    );
  }

  @override
  Future<ApiResponse> submitLsa(SubmissionRequest request) async {
    callCount++; // Increment call count
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Case 3 
    if (simulateHttp500) {
      print('API_REQUEST: Simulating HTTP 500 error');
      return ApiResponse.quarantineFailure();
    }

    if (simulateNullResponse) {
      print('API_REQUEST: Simulating null status response');
      
      return ApiResponse.failure(
        message: 'Data Quarantined – Compliance Failure',
        statusCode: 500,
      );
      
    }
    

    // Validate required metadata headers
    if (request.traceId.isEmpty) {
      return ApiResponse.failure(
        message: 'Missing trace_id metadata header',
        statusCode: 400,
      );
    }

    if (request.logicHash.isEmpty) {
      return ApiResponse.failure(
        message: 'Missing logic_hash metadata header',
        statusCode: 400,
      );
    }

    // Log the submission for demonstration
    print('API_REQUEST: Submitting LSA verification to https://api.habotconnect.com/v1/compliance/verify');
    print('API_REQUEST: x-trace-id: ${request.traceId}');
    print('API_REQUEST: x-logic-hash: ${request.logicHash}');
    print('API_REQUEST: Request payload: ${request.data.toMap()}');

    // Simulate successful submission
    return ApiResponse.success(
      message: 'LSA verification submitted successfully',
      data: {
        'submissionId': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'success',
      },
    );
  }
  
  /// Reset call count
  void resetCallCount() {
    callCount = 0;
  }

  /// Enable Case 3 
  void enableHttp500Simulation() {
    simulateHttp500 = true;
    simulateNullResponse = false;
  }

  /// Enable Case 3 
  void enableNullResponseSimulation() {
    simulateNullResponse = true;
    simulateHttp500 = false;
  }

  /// Disable Case 3 
  void disableSimulation() {
    simulateHttp500 = false;
    simulateNullResponse = false;
  }
}