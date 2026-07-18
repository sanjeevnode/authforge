/// Data-layer exceptions. Datasources throw these; repositories catch them and
/// convert to Failures (dartz Left) so exceptions never leak past the data layer.
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
}

class InvalidOtpUriException implements Exception {
  final String message;
  InvalidOtpUriException(this.message);
}
