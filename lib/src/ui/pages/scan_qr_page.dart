import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:authforge/src/core/constants/scan_qr_constants.dart';
import 'package:authforge/src/core/theme/app_colors.dart';
import 'package:authforge/src/ui/cubit/vault_cubit.dart';
import 'package:authforge/src/ui/pages/manual_entry_page.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false; // guard: fire once per scan

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _handled = true;

    final ok = await context.read<VaultCubit>().addFromUri(raw);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      // let them try again / show the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<VaultCubit>().state.errorMessage ??
                ScanQrConstants.invalidQr,
          ),
          backgroundColor: AppColors.error,
        ),
      );
      _handled = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScanQrConstants.title),
        backgroundColor: AppColors.background,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.keyboard, color: AppColors.accent),
            label: const Text(
              ScanQrConstants.manualAction,
              style: TextStyle(color: AppColors.accent),
            ),
            onPressed: () {
              final cubit = context.read<VaultCubit>();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const ManualEntryPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // simple framing overlay
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Positioned(
            bottom: 80,
            child: Text(
              ScanQrConstants.framePrompt,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
