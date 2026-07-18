import 'package:dartz/dartz.dart';

import 'package:authforge/src/core/error/failures.dart';
import 'package:authforge/src/domain/entities/otp_account.dart';

/// The vault contract. Domain defines it; data implements it.
/// `Either<Failure, T>`: Left = failure, Right = success.
abstract class VaultRepository {
  Future<Either<Failure, List<OtpAccount>>> getAccounts();

  /// Parse an otpauth:// URI (from a scanned QR) and store the account.
  Future<Either<Failure, OtpAccount>> addFromUri(String otpauthUri);

  /// Store a manually-entered account.
  Future<Either<Failure, OtpAccount>> addManual({
    required String label,
    required String issuer,
    required String secret,
  });

  Future<Either<Failure, Unit>> deleteAccount(String id);
}
