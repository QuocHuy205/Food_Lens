import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  static const String accessTokenKey = 'auth.firebase_id_token';
  static const String refreshTokenKey = 'auth.firebase_refresh_token';
  static const String uidKey = 'auth.uid';
  static const String emailKey = 'auth.email';
  static const String savedAtKey = 'auth.saved_at';

  static Future<void> save({
    required String idToken,
    String? refreshToken,
    required String uid,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, idToken);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }

    await prefs.setString(uidKey, uid);

    if (email != null && email.isNotEmpty) {
      await prefs.setString(emailKey, email);
    }

    await prefs.setInt(savedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(uidKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(uidKey);
    await prefs.remove(emailKey);
    await prefs.remove(savedAtKey);
  }
}
