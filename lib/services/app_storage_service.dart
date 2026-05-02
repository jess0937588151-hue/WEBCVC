import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockflow_flutter_pro/models/app_state_bundle.dart';
import 'package:stockflow_flutter_pro/models/user_account.dart';

class AppStorageService {
  static const _bundleKey = 'stockflow.bundle';
  static const _currentUserKey = 'stockflow.currentUser';

  Future<AppStateBundle?> loadBundle() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bundleKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return AppStateBundle.fromRawJson(raw);
  }

  Future<void> saveBundle(AppStateBundle bundle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bundleKey, bundle.toRawJson());
  }

  Future<UserAccount?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveCurrentUser(UserAccount? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
      return;
    }
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
