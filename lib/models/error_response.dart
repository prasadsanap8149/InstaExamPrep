class ErrorResponse {
  final String? errorCode;
  final String? errorMessage;
  final DateTime timestamp;

  ErrorResponse({
    this.errorCode,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ErrorResponse.fromMap(Map<String, dynamic> map) {
    return ErrorResponse(
      errorCode: map['code'] as String?,
      errorMessage: map['message'] as String?,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': errorCode,
      'message': errorMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
