part of 'vault_cubit.dart';

enum VaultStatus { initial, loading, loaded, error }

class VaultState extends Equatable {
  final VaultStatus status;
  final List<OtpAccount> accounts;
  final String? errorMessage;

  const VaultState({
    this.status = VaultStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  VaultState copyWith({
    VaultStatus? status,
    List<OtpAccount>? accounts,
    String? errorMessage,
  }) {
    return VaultState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accounts, errorMessage];
}
