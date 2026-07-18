import 'package:flutter/material.dart';

import 'src/src.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const AuthForgeApp());
}
