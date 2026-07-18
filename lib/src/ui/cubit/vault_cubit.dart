import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/domain.dart';

part 'vault_state.dart';

/// Drives the account-list screens. Talks only to use-cases (domain),
/// never to storage directly.
class VaultCubit extends Cubit<VaultState> {
  final GetAccounts _getAccounts;
  final AddAccountFromUri _addAccountFromUri;
  final AddAccountManual _addAccountManual;
  final DeleteAccount _deleteAccount;

  VaultCubit({
    required GetAccounts getAccounts,
    required AddAccountFromUri addAccountFromUri,
    required AddAccountManual addAccountManual,
    required DeleteAccount deleteAccount,
  })  : _getAccounts = getAccounts,
        _addAccountFromUri = addAccountFromUri,
        _addAccountManual = addAccountManual,
        _deleteAccount = deleteAccount,
        super(const VaultState());

  Future<void> loadAccounts() async {
    emit(state.copyWith(status: VaultStatus.loading));
    final result = await _getAccounts();
    result.fold(
      (failure) => emit(state.copyWith(
          status: VaultStatus.error, errorMessage: failure.message)),
      (accounts) =>
          emit(state.copyWith(status: VaultStatus.loaded, accounts: accounts)),
    );
  }

  Future<bool> addFromUri(String uri) async {
    final result = await _addAccountFromUri(uri);
    return result.fold(
      (failure) {
        emit(state.copyWith(
            status: VaultStatus.error, errorMessage: failure.message));
        return false;
      },
      (_) {
        loadAccounts();
        return true;
      },
    );
  }

  Future<bool> addManual({
    required String label,
    required String issuer,
    required String secret,
  }) async {
    final result =
        await _addAccountManual(label: label, issuer: issuer, secret: secret);
    return result.fold(
      (failure) {
        emit(state.copyWith(
            status: VaultStatus.error, errorMessage: failure.message));
        return false;
      },
      (_) {
        loadAccounts();
        return true;
      },
    );
  }

  Future<void> delete(String id) async {
    final result = await _deleteAccount(id);
    result.fold(
      (failure) => emit(state.copyWith(
          status: VaultStatus.error, errorMessage: failure.message)),
      (_) => loadAccounts(),
    );
  }
}
