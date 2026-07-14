import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Salted-hash password gate for Creator Mode. The plaintext password is
/// never stored — only its salted SHA-256 hash lives in Hive
/// (see SettingsModel).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _salt = 'our-story-hanif-santona-2026';

  String hash(String plainPassword) {
    final bytes = utf8.encode('$_salt::$plainPassword');
    return sha256.convert(bytes).toString();
  }

  bool verify(String plainPassword, String storedHash) {
    return hash(plainPassword) == storedHash;
  }
}
