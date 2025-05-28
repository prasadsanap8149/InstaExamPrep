class Response {
  int statusCode;
  String message;

  Response({required this.statusCode, required this.message});

  // Convert the Response object to a string representation
  @override
  String toString() {
    return 'Response(statusCode: $statusCode, message: $message)';
  }

  // Convert the Response object to a Map representation
  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'message': message,
    };
  }
}
