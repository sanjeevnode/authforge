import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/core.dart';
import 'ui/ui.dart';

class AuthForgeApp extends StatelessWidget {
  const AuthForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuthForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: BlocProvider(
        create: (_) => sl<VaultCubit>()..loadAccounts(),
        child: const AccountListPage(),
      ),
    );
  }
}
