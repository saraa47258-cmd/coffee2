import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ty_cafe/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> loadProfile();
  Future<void> saveProfile(Profile profile);
  Future<void> clearProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  static const _key = 'app_profile_v1';

  final SharedPreferences prefs;
  ProfileRepositoryImpl(this.prefs);

  @override
  Future<Profile?> loadProfile() async {
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return Profile.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    final jsonStr = json.encode(profile.toMap());
    await prefs.setString(_key, jsonStr);
  }

  @override
  Future<void> clearProfile() async {
    await prefs.remove(_key);
  }
}
