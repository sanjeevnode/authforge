/// Messages + fallbacks used by the vault data layer (repository, datasource).
class VaultConstants {
  VaultConstants._();

  // Fallback field values
  static const String defaultLabel = 'Account';
  static const String defaultIssuer = 'Unknown';

  // Validation / parse errors
  static const String emptySecret = 'Secret cannot be empty.';
  static const String invalidTotpQr = 'Not a valid TOTP QR code.';
  static const String qrNoSecret = 'QR code has no secret.';

  // Storage errors (append the underlying cause)
  static const String readFailed = 'Failed to read vault';
  static const String writeFailed = 'Failed to write vault';
}
