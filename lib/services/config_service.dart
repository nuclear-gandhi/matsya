import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing application configuration and secure storage
class ConfigService {
  static const String _hfTokenKey = 'huggingface_token';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Get the Hugging Face API token from secure storage
  /// Returns null if no token is stored
  static Future<String?> getHuggingFaceToken() async {
    try {
      return await _storage.read(key: _hfTokenKey);
    } catch (e) {
      // If secure storage fails, return null
      return null;
    }
  }

  /// Set the Hugging Face API token in secure storage
  static Future<void> setHuggingFaceToken(String token) async {
    try {
      await _storage.write(key: _hfTokenKey, value: token);
    } catch (e) {
      // Log error but don't throw - allow app to continue
      debugPrint('Failed to save Hugging Face token: $e');
    }
  }

  /// Delete the Hugging Face API token from secure storage
  static Future<void> deleteHuggingFaceToken() async {
    try {
      await _storage.delete(key: _hfTokenKey);
    } catch (e) {
      debugPrint('Failed to delete Hugging Face token: $e');
    }
  }
}

