/// App-wide constants. Server base URL is here for the auth feature (later);
/// the authenticator vault is offline and needs no server.
class AppConstants {
  AppConstants._();

  // Deployed identity server (used by the auth feature).
  static const String apiBaseUrl =
      'https://server.authforge.sanjeevnode.in/api/v1';

  static const int totpDigits = 6;
  static const int totpPeriodSeconds = 30;

  // secure_storage key under which the account list JSON is stored.
  static const String vaultStorageKey = 'authforge_vault_accounts';

  // Font Family
  static const String fontFamilyMonospace = 'monospace';
}
