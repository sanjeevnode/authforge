class AccountDetailConstants {
  AccountDetailConstants._();

  static const String title = 'Account Details';
  static const String issuerLabel = 'Issuer';
  static const String accountLabel = 'Account';
  static const String secretLabel = 'Secret';
  static const String addedLabel = 'Added';
  static const String currentCodeLabel = 'Current code';
  static const String deleteButton = 'Delete account';

  // Confirmation dialog
  static const String dialogTitle = 'Delete account?';
  static const String dialogMessage =
      'This removes the account and its secret from this device. '
      'You will no longer be able to generate codes for it.';
  static const String dialogCancel = 'Cancel';
  static const String dialogConfirm = 'Delete';
}
