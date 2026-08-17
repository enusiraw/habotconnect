
abstract class SubmissionError {
  final String message;
  final String? details;

  SubmissionError(this.message, {this.details});

  @override
  String toString() => 'SubmissionError: $message${details != null ? " ($details)" : ""}';
}

//Validation failure error
class ValidationFailure extends SubmissionError {
  final List<String> fieldErrors;

  ValidationFailure(super.message, {this.fieldErrors = const [], super.details});
}

//Lineage validation failure error
class LineageFailure extends SubmissionError {
  LineageFailure(super.message, {super.details});
}

//Compliance validation failure error
class ComplianceFailure extends SubmissionError {
  ComplianceFailure(super.message, {super.details});
}

//Quarantine failure error
class QuarantineFailure extends SubmissionError {
  QuarantineFailure(super.message, {super.details});
}

//Network failure error
class NetworkFailure extends SubmissionError {
  NetworkFailure(super.message, {super.details});
}

// Server failure error
class ServerFailure extends SubmissionError {
  final int? statusCode;

  ServerFailure(super.message, {this.statusCode, super.details});
}

// Unknown failure error
class UnknownFailure extends SubmissionError {
  final dynamic originalError;

  UnknownFailure(super.message, {this.originalError, super.details});
}

//Result type for operations that can fail
class Result<T> {
  final T? data;
  final SubmissionError? error;
  final bool isSuccess;

  Result.success(T this.data)
      : error = null,
        isSuccess = true;

  Result.failure(SubmissionError this.error)
      : data = null,
        isSuccess = false;

  bool get isFailure => !isSuccess;

  //Map success data to a new type
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data as T));
    }
    return Result.failure(error!);
  }

  // Execute callback on success
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data as T);
    }
    return this;
  }

  //Execute callback on failure
  Result<T> onFailure(void Function(SubmissionError error) callback) {
    if (isFailure && error != null) {
      callback(error!);
    }
    return this;
  }
}