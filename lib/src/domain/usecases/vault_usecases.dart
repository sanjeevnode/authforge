import 'package:dartz/dartz.dart';

import 'package:authforge/src/core/error/failures.dart';
import 'package:authforge/src/domain/entities/otp_account.dart';
import 'package:authforge/src/domain/repositories/vault_repository.dart';

/// Use-cases: the actions the UI can perform. Thin wrappers over the repository,
/// but they're the presentation layer's only entry point into domain logic.

class GetAccounts {
  final VaultRepository _repo;
  GetAccounts(this._repo);
  Future<Either<Failure, List<OtpAccount>>> call() => _repo.getAccounts();
}

class AddAccountFromUri {
  final VaultRepository _repo;
  AddAccountFromUri(this._repo);
  Future<Either<Failure, OtpAccount>> call(String otpauthUri) =>
      _repo.addFromUri(otpauthUri);
}

class AddAccountManual {
  final VaultRepository _repo;
  AddAccountManual(this._repo);
  Future<Either<Failure, OtpAccount>> call({
    required String label,
    required String issuer,
    required String secret,
  }) => _repo.addManual(label: label, issuer: issuer, secret: secret);
}

class DeleteAccount {
  final VaultRepository _repo;
  DeleteAccount(this._repo);
  Future<Either<Failure, Unit>> call(String id) => _repo.deleteAccount(id);
}
