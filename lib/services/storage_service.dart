import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON persistence layer on top of shared_preferences. All player
/// progress is stored as a single JSON blob for simplicity and robustness.
class StorageService {
  static const _key = 'bright_fortune_save_v1';

  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }
}
