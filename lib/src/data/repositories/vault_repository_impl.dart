import 'package:dartz/dartz.dart';

import 'package:authforge/src/core/constants/vault_constants.dart';
import 'package:authforge/src/core/error/exceptions.dart';
import 'package:authforge/src/core/error/failures.dart';
import 'package:authforge/src/domain/entities/otp_account.dart';
import 'package:authforge/src/domain/repositories/vault_repository.dart';
import 'package:authforge/src/data/datasources/vault_local_datasource.dart';
import 'package:authforge/src/data/models/otp_account_model.dart';

class VaultRepositoryImpl implements VaultRepository {
  final VaultLocalDataSource _local;
  VaultRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<OtpAccount>>> getAccounts() async {
    try {
      return Right(await _local.readAll());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, OtpAccount>> addFromUri(String otpauthUri) async {
    try {
      final account = _parseOtpauthUri(otpauthUri);
      return _persist(account);
    } on InvalidOtpUriException catch (e) {
      return Left(ScanFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, OtpAccount>> addManual({
    required String label,
    required String issuer,
    required String secret,
  }) async {
    final cleaned = secret.replaceAll(' ', '').toUpperCase();
    if (cleaned.isEmpty) {
      return const Left(ValidationFailure(VaultConstants.emptySecret));
    }
    try {
      return _persist(
        OtpAccountModel(
          id: _newId(),
          label: label.isEmpty ? VaultConstants.defaultLabel : label,
          issuer: issuer,
          secret: cleaned,
        ),
      );
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount(String id) async {
    try {
      final all = await _local.readAll();
      all.removeWhere((a) => a.id == id);
      await _local.writeAll(all);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  // --- helpers ---

  Future<Either<Failure, OtpAccount>> _persist(OtpAccountModel account) async {
    final all = await _local.readAll();
    all.add(account);
    await _local.writeAll(all);
    return Right(account);
  }

  /// Parse otpauth://totp/ISSUER:LABEL?secret=...&issuer=...
  OtpAccountModel _parseOtpauthUri(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'otpauth' || uri.host != 'totp') {
      throw InvalidOtpUriException(VaultConstants.invalidTotpQr);
    }
    final secret = uri.queryParameters['secret'];
    if (secret == null || secret.isEmpty) {
      throw InvalidOtpUriException(VaultConstants.qrNoSecret);
    }
    // path is "/ISSUER:LABEL" or "/LABEL"; strip leading slash and decode
    final pathLabel = Uri.decodeComponent(
      uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '',
    );
    String issuer = uri.queryParameters['issuer'] ?? '';
    String label = pathLabel;
    if (pathLabel.contains(':')) {
      final parts = pathLabel.split(':');
      if (issuer.isEmpty) issuer = parts.first;
      label = parts.sublist(1).join(':');
    }
    return OtpAccountModel(
      id: _newId(),
      label: label.isEmpty ? VaultConstants.defaultLabel : label,
      issuer: issuer.isEmpty ? VaultConstants.defaultIssuer : issuer,
      secret: secret.toUpperCase(),
    );
  }

  // Simple time-based id; no Math.random dependency needed.
  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
