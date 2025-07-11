import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._();
  static SharedPreferencesHelper get instance => _instance;

  SharedPreferences? _prefs;

  // Keys for different preferences
  static const String _keyDarkMode = 'isDarkMode';
  static const String _keyFirstLaunch = 'isFirstLaunch';
  static const String _keyLanguage = 'selectedLanguage';
  static const String _keyNotifications = 'notificationsEnabled';
  static const String _keyFontSize = 'fontSize';
  static const String _keyLastUserEmail = 'lastUserEmail';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'SharedPreferencesHelper not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

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

  bool get isFirstLaunch => prefs.getBool(_keyFirstLaunch) ?? true;

  Future<bool> setFirstLaunch(bool value) async {
    return await prefs.setBool(_keyFirstLaunch, value);
  }

  Future<bool> markFirstLaunchCompleted() async {
    return await setFirstLaunch(false);
  }

  String get selectedLanguage => prefs.getString(_keyLanguage) ?? 'en';

  Future<bool> setSelectedLanguage(String languageCode) async {
    return await prefs.setString(_keyLanguage, languageCode);
  }

  bool get notificationsEnabled => prefs.getBool(_keyNotifications) ?? true;

  Future<bool> setNotificationsEnabled(bool value) async {
    return await prefs.setBool(_keyNotifications, value);
  }

  double get fontSize => prefs.getDouble(_keyFontSize) ?? 16.0;

  Future<bool> setFontSize(double size) async {
    return await prefs.setDouble(_keyFontSize, size);
  }

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

  Future<bool> setJsonString(String key, String jsonString) async {
    return await prefs.setString(key, jsonString);
  }

  String? getJsonString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setStringList(String key, List<String> values) async {
    return await prefs.setStringList(key, values);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

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

extension SharedPreferencesExtension on SharedPreferencesHelper {
  Future<void> applyTheme(bool isDark) async {
    await setDarkMode(isDark);
  }

  Future<void> resetToDefaults() async {
    await setDarkMode(false);
    await setNotificationsEnabled(true);
    await setFontSize(16.0);
    await setSelectedLanguage('en');
  }
}
