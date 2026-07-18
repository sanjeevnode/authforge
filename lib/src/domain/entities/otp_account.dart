import 'package:equatable/equatable.dart';

/// A stored TOTP account. Pure domain object — no JSON, no framework.
/// The secret is base32 (as parsed from an otpauth:// URI).
class OtpAccount extends Equatable {
  final String id;
  final String label; // account name, e.g. the email
  final String issuer; // service name, e.g. "AuthForge"
  final String secret; // base32 TOTP secret
  final DateTime createdAt; // when this account was added (UTC)

  const OtpAccount({
    required this.id,
    required this.label,
    required this.issuer,
    required this.secret,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, label, issuer, secret, createdAt];
}
