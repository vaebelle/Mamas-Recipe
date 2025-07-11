import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing SharedPreferences operations
/// Handles theme preferences and other app settings
class SharedPreferencesHelper {
  // Private constructor for singleton pattern
  SharedPreferencesHelper._();

  // Singleton instance
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._();
  static SharedPreferencesHelper get instance => _instance;

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Keys for different preferences
  static const String _keyDarkMode = 'isDarkMode';
  static const String _keyFirstLaunch = 'isFirstLaunch';
  static const String _keyLanguage = 'selectedLanguage';
  static const String _keyNotifications = 'notificationsEnabled';
  static const String _keyFontSize = 'fontSize';
  static const String _keyLastUserEmail = 'lastUserEmail';

  // ===========================
  // INITIALIZATION
  // ===========================

  /// Initialize SharedPreferences
  /// Call this in main() before runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  /// Throws exception if not initialized
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'SharedPreferencesHelper not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  // ===========================
  // THEME PREFERENCES
  // ===========================

  /// Get dark mode preference
  /// Returns false by default (light mode)
  bool get isDarkMode => prefs.getBool(_keyDarkMode) ?? false;

  /// Set dark mode preference
  Future<bool> setDarkMode(bool value) async {
    return await prefs.setBool(_keyDarkMode, value);
  }

  /// Toggle dark mode and return new value
  Future<bool> toggleDarkMode() async {
    final newValue = !isDarkMode;
    await setDarkMode(newValue);
    return newValue;
  }

  // ===========================
  // APP PREFERENCES
  // ===========================

  /// Check if this is the first app launch
  bool get isFirstLaunch => prefs.getBool(_keyFirstLaunch) ?? true;

  /// Set first launch flag
  Future<bool> setFirstLaunch(bool value) async {
    return await prefs.setBool(_keyFirstLaunch, value);
  }

  /// Mark first launch as completed
  Future<bool> markFirstLaunchCompleted() async {
    return await setFirstLaunch(false);
  }

  /// Get selected language
  String get selectedLanguage => prefs.getString(_keyLanguage) ?? 'en';

  /// Set selected language
  Future<bool> setSelectedLanguage(String languageCode) async {
    return await prefs.setString(_keyLanguage, languageCode);
  }

  /// Get notifications enabled status
  bool get notificationsEnabled => prefs.getBool(_keyNotifications) ?? true;

  /// Set notifications enabled status
  Future<bool> setNotificationsEnabled(bool value) async {
    return await prefs.setBool(_keyNotifications, value);
  }

  /// Get font size preference
  double get fontSize => prefs.getDouble(_keyFontSize) ?? 16.0;

  /// Set font size preference
  Future<bool> setFontSize(double size) async {
    return await prefs.setDouble(_keyFontSize, size);
  }

  // ===========================
  // USER PREFERENCES
  // ===========================

  /// Get last logged in user email
  String? get lastUserEmail => prefs.getString(_keyLastUserEmail);

  /// Set last logged in user email
  Future<bool> setLastUserEmail(String email) async {
    return await prefs.setString(_keyLastUserEmail, email);
  }

  /// Clear last user email
  Future<bool> clearLastUserEmail() async {
    return await prefs.remove(_keyLastUserEmail);
  }

  // ===========================
  // UTILITY METHODS
  // ===========================

  /// Clear all preferences
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  /// Remove specific preference by key
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return prefs.getKeys();
  }

  // ===========================
  // ADVANCED METHODS
  // ===========================

  /// Save complex object as JSON string
  Future<bool> setJsonString(String key, String jsonString) async {
    return await prefs.setString(key, jsonString);
  }

  /// Get JSON string
  String? getJsonString(String key) {
    return prefs.getString(key);
  }

  /// Save list of strings
  Future<bool> setStringList(String key, List<String> values) async {
    return await prefs.setStringList(key, values);
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  // ===========================
  // DEBUG METHODS
  // ===========================

  /// Print all stored preferences (for debugging)
  void debugPrintAll() {
    print('=== SharedPreferences Debug ===');
    for (String key in getAllKeys()) {
      final value = prefs.get(key);
      print('$key: $value (${value.runtimeType})');
    }
    print('==============================');
  }

  /// Get preferences summary
  Map<String, dynamic> getPreferencesSummary() {
    return {
      'isDarkMode': isDarkMode,
      'isFirstLaunch': isFirstLaunch,
      'selectedLanguage': selectedLanguage,
      'notificationsEnabled': notificationsEnabled,
      'fontSize': fontSize,
      'lastUserEmail': lastUserEmail,
      'totalKeys': getAllKeys().length,
    };
  }
}

/// Extension methods for easier access
extension SharedPreferencesExtension on SharedPreferencesHelper {
  /// Quick access to common theme operations
  Future<void> applyTheme(bool isDark) async {
    await setDarkMode(isDark);
  }

  /// Reset all app preferences to defaults
  Future<void> resetToDefaults() async {
    await setDarkMode(false);
    await setNotificationsEnabled(true);
    await setFontSize(16.0);
    await setSelectedLanguage('en');
    // Don't reset first launch or user email
  }
}
