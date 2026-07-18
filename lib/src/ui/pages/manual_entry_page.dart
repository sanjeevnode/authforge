import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../cubit/vault_cubit.dart';

class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  @override
  State<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  final _issuer = TextEditingController();
  final _label = TextEditingController();
  final _secret = TextEditingController();

  @override
  void dispose() {
    _issuer.dispose();
    _label.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await context.read<VaultCubit>().addManual(
          issuer: _issuer.text.trim(),
          label: _label.text.trim(),
          secret: _secret.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.read<VaultCubit>().state.errorMessage ?? 'Failed to add'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Manually'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _issuer,
              decoration: const InputDecoration(hintText: 'Issuer (e.g. AuthForge)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _label,
              decoration: const InputDecoration(hintText: 'Account (e.g. your email)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _secret,
              decoration: const InputDecoration(hintText: 'Secret key (base32)'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Add account')),
          ],
        ),
      ),
    );
  }
}
