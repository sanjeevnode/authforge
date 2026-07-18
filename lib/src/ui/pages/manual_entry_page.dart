import 'package:authforge/src/core/constants/manual_entry_constants.dart';
import 'package:authforge/src/core/theme/app_colors.dart';
import 'package:authforge/src/ui/cubit/vault_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            context.read<VaultCubit>().state.errorMessage ??
                ManualEntryConstants.failed,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ManualEntryConstants.title),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _issuer,
              decoration: const InputDecoration(
                hintText: ManualEntryConstants.issuerHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                hintText: ManualEntryConstants.labelHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _secret,
              decoration: const InputDecoration(
                hintText: ManualEntryConstants.secretHint,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text(ManualEntryConstants.addButton),
            ),
          ],
        ),
      ),
    );
  }
}
