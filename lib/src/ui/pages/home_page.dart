import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:authforge/src/core/core.dart';
import 'package:authforge/src/ui/cubit/cubit.dart';
import 'package:authforge/src/ui/pages/scan_qr_page.dart';
import 'package:authforge/src/ui/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          HomeConstants.title,
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text(HomeConstants.addButton),
        onPressed: () async {
          final cubit = context.read<VaultCubit>();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BlocProvider.value(value: cubit, child: const ScanQrPage()),
            ),
          );
        },
      ),
      body: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) {
          if (state.status == VaultStatus.loading && state.accounts.isEmpty) {
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
          Icon(
            Icons.shield_outlined,
            size: 72,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            HomeConstants.emptyTitle,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            HomeConstants.emptySubtitle,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
