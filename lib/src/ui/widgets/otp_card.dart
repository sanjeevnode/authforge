import 'dart:async';

import 'package:authforge/src/core/constants/otp_card_constants.dart';
import 'package:authforge/src/core/theme/app_colors.dart';
import 'package:authforge/src/domain/domain.dart';
import 'package:authforge/src/ui/widgets/countdown_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One account: issuer + label, the rolling 6-digit code, and the countdown ring.
/// Owns a 1s Timer that recomputes the code as the TOTP window advances.
/// Tapping the card opens the detail screen; tapping the code copies it.
class OtpCard extends StatefulWidget {
  final OtpAccount account;
  final VoidCallback? onTap;
  const OtpCard({super.key, required this.account, this.onTap});

  @override
  State<OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends State<OtpCard> {
  Timer? _timer;
  String _code = OtpCardConstants.codePlaceholder;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.issuer,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.account.label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(OtpCardConstants.codeCopied),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text(
                        _formattedCode,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CountdownRing(secondsRemaining: _remaining),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
