import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/otp_account.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/vault_local_datasource.dart';
import '../models/otp_account_model.dart';

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
      return const Left(ValidationFailure('Secret cannot be empty.'));
    }
    try {
      return _persist(OtpAccountModel(
        id: _newId(),
        label: label.isEmpty ? 'Account' : label,
        issuer: issuer,
        secret: cleaned,
      ));
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
      throw InvalidOtpUriException('Not a valid TOTP QR code.');
    }
    final secret = uri.queryParameters['secret'];
    if (secret == null || secret.isEmpty) {
      throw InvalidOtpUriException('QR code has no secret.');
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
      label: label.isEmpty ? 'Account' : label,
      issuer: issuer.isEmpty ? 'Unknown' : issuer,
      secret: secret.toUpperCase(),
    );
  }

  // Simple time-based id; no Math.random dependency needed.
  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
