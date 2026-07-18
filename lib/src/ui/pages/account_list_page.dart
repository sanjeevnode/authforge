import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../cubit/vault_cubit.dart';
import '../widgets/widgets.dart';
import 'scan_qr_page.dart';

class AccountListPage extends StatelessWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: () async {
          final cubit = context.read<VaultCubit>();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const ScanQrPage(),
              ),
            ),
          );
        },
      ),
      body: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) {
          if (state.status == VaultStatus.loading &&
              state.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.accounts.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: state.accounts.length,
            itemBuilder: (context, i) {
              final account = state.accounts[i];
              return OtpCard(
                account: account,
                onDelete: () => context.read<VaultCubit>().delete(account.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined,
              size: 72, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No accounts yet',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Tap Add to scan a QR code',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
