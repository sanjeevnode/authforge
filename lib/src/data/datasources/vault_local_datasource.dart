import 'dart:convert';

import 'package:authforge/src/core/constants/app_constants.dart';
import 'package:authforge/src/core/constants/vault_constants.dart';
import 'package:authforge/src/core/error/exceptions.dart';
import 'package:authforge/src/data/models/otp_account_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the account list in encrypted secure storage as a JSON array.
abstract class VaultLocalDataSource {
  Future<List<OtpAccountModel>> readAll();
  Future<void> writeAll(List<OtpAccountModel> accounts);
}

class VaultLocalDataSourceImpl implements VaultLocalDataSource {
  final FlutterSecureStorage _storage;
  VaultLocalDataSourceImpl(this._storage);

  @override
  Future<List<OtpAccountModel>> readAll() async {
    try {
      final raw = await _storage.read(key: AppConstants.vaultStorageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => OtpAccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('${VaultConstants.readFailed}: $e');
    }
  }

  @override
  Future<void> writeAll(List<OtpAccountModel> accounts) async {
    try {
      final raw = jsonEncode(accounts.map((a) => a.toJson()).toList());
      await _storage.write(key: AppConstants.vaultStorageKey, value: raw);
    } catch (e) {
      throw StorageException('${VaultConstants.writeFailed}: $e');
    }
  }
}
