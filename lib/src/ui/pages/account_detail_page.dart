import 'dart:async';

import 'package:authforge/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detail view for one account: issuer/label/secret, when it was added, the live
/// rolling code, and a delete action guarded by a confirmation dialog.
class AccountDetailPage extends StatefulWidget {
  final OtpAccount account;
  const AccountDetailPage({super.key, required this.account});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  Timer? _timer;
  String _code = '------';
  int _remaining = 30;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  void _refresh() {
    setState(() {
      _code = TotpService.generateCode(widget.account.secret);
      _remaining = TotpService.secondsRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedCode => _code.length == 6
      ? '${_code.substring(0, 3)} ${_code.substring(3)}'
      : _code;

  String _formatAdded(DateTime utc) {
    final d = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          AccountDetailConstants.dialogTitle,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          AccountDetailConstants.dialogMessage,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              AccountDetailConstants.dialogCancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AccountDetailConstants.dialogConfirm,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<VaultCubit>().delete(widget.account.id);
    if (mounted) Navigator.pop(context); // back to the list
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AccountDetailConstants.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // live code card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AccountDetailConstants.currentCodeLabel,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formattedCode,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CountdownRing(secondsRemaining: _remaining),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(
            label: AccountDetailConstants.issuerLabel,
            value: a.issuer,
          ),
          _DetailRow(
            label: AccountDetailConstants.accountLabel,
            value: a.label,
          ),
          // _DetailRow(
          //   label: AccountDetailConstants.secretLabel,
          //   value: a.secret,
          //   mono: true,
          // ),
          _DetailRow(
            label: AccountDetailConstants.addedLabel,
            value: _formatAdded(a.createdAt),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textPrimary,
            ),
            label: const Text(AccountDetailConstants.deleteButton),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontFamily: AppConstants.fontFamilyMonospace,
            ),
          ),
        ],
      ),
    );
  }
}
