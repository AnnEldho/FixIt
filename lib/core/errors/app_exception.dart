/// A user-friendly error. Repositories convert Firebase errors into this so
/// the UI never has to know about Firebase error codes.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}
