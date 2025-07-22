import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/screens/login.dart';
import 'package:mama_recipe/screens/authentication.dart';
import 'package:mama_recipe/widgets/settingsTile.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isDarkMode = false;
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  // Dark mode colors
  static const Color _darkBackground = Color(0xFF1C1C1E);
  static const Color _darkSecondaryBackground = Color(0xFF2C2C2E);
  static const Color _darkTertiaryBackground = Color(0xFF3A3A3C);
  static const Color _darkPrimaryText = Color(0xFFFFFFFF);
  static const Color _darkSecondaryText = Color(0xFFAEAEB2);
  static const Color _darkSeparator = Color(0xFF38383A);

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _initializeUserData();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    setState(() {
      isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      isDarkMode = value;
    });

    await SharedPreferencesHelper.instance.setDarkMode(value);
  }

  void _handleNotifications() {
    _showSuccessDialog(
      'Coming Soon',
      'Notification settings will be available in a future update.',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    final currentUser = authService.value.currentUser;
    if (currentUser?.email != null) {
      _emailController.text = currentUser!.email!;
    }
  }

  /// Handle password reset functionality
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Navigator.pop(context);
      _showErrorDialog('Please enter your email address.');
      return;
    }

    Navigator.pop(context);

    setState(() {
      isLoading = true;
    });

    try {
      await authService.value.resetPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog(
          'Password Reset Email Sent',
          'Check your email for password reset instructions.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = authService.value.getErrorMessage(e);
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Handle user logout functionality - FIXED
  Future<void> _logout() async {
    Navigator.pop(context); // Close the dialog first

    setState(() {
      isLoading = true;
    });

    try {
      await authService.value.signOut();

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Navigate back to Authentication screen and clear the entire navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const Authentication()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Failed to logout. Please try again.');
      }
    }
  }

  /// Handle app info
  void _showAppInfo() {
    _showSuccessDialog(
      'Mama\'s Recipes',
      'Share your culinary creations with the world.\n\nVersion 1.0.0\nMade with ❤️ in Flutter',
    );
  }

  /// Handle help and support
  void _showHelpSupport() {
    _showSuccessDialog(
      'Help & Support',
      'For support, please contact us at:\nmamasrecipes.support@gmail.com',
    );
  }

  Color _adaptiveBackground(BuildContext context) {
    // Return transparent since we're using gradient background
    return const Color(0x00000000);
  }

  Color _adaptiveSecondaryBackground(BuildContext context) {
    return isDarkMode
        ? const Color(0xFF2C2C2E).withOpacity(
            0.95,
          ) // More opaque for better contrast
        : const Color(
            0xFFFFFDF8,
          ).withOpacity(0.95); // Warmer white with opacity
  }

  Color _adaptivePrimaryText(BuildContext context) {
    return isDarkMode
        ? const Color(0xFFE5E5E7) // Brighter white for better contrast
        : const Color(
            0xFF2C1810,
          ); // Darker for better contrast against gradient
  }

  Color _adaptiveSecondaryText(BuildContext context) {
    return isDarkMode
        ? const Color(0xFFD1D1D6) // Brighter grey
        : const Color(0xFF8B4513); // Darker brown for better contrast
  }

  Color _adaptiveSeparator(BuildContext context) {
    return isDarkMode
        ? const Color(0xFF48484A).withOpacity(0.8)
        : const Color(0xFFD2691E).withOpacity(0.2); // Orange-tinted separator
  }

  void _showResetPasswordDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            'Reset Password',
            style: TextStyle(color: _adaptivePrimaryText(context)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enter your email address to receive password reset instructions.',
                style: TextStyle(
                  fontSize: 14,
                  color: _adaptiveSecondaryText(context),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                style: TextStyle(color: _adaptivePrimaryText(context)),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? _darkTertiaryBackground
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(12),
                placeholderStyle: TextStyle(
                  color: _adaptiveSecondaryText(context),
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Reset Email'),
              onPressed: () => _resetPassword(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(color: _adaptivePrimaryText(context)),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: _adaptiveSecondaryText(context)),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Logout'),
              onPressed: () => _logout(),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: _adaptivePrimaryText(context)),
          ),
          content: Text(
            message,
            style: TextStyle(color: _adaptiveSecondaryText(context)),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(color: _adaptivePrimaryText(context)),
          ),
          content: Text(
            message,
            style: TextStyle(color: _adaptiveSecondaryText(context)),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final currentUser = authService.value.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _adaptiveSecondaryBackground(context),
          borderRadius: BorderRadius.circular(12), // Slightly more rounded
          // ADD SUBTLE SHADOW FOR BETTER DEPTH
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? CupertinoColors.black.withOpacity(0.3)
                  : CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          // ADD SUBTLE BORDER FOR BETTER DEFINITION
          border: Border.all(
            color: isDarkMode
                ? CupertinoColors.systemOrange.withOpacity(0.3)
                : const Color(0xFFD2691E).withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                // ENHANCED AVATAR WITH GRADIENT
                gradient: const LinearGradient(
                  colors: [CupertinoColors.systemOrange, Color(0xFFFF6B35)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemOrange.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                currentUser?.photoURL != null
                    ? CupertinoIcons.person_fill
                    : CupertinoIcons.person_circle_fill,
                color: CupertinoColors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _adaptivePrimaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentUser?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      color: _adaptiveSecondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return SettingsSection(
      title: 'Account',
      backgroundColor: _adaptiveSecondaryBackground(context),
      titleColor: _adaptiveSecondaryText(context),
      children: [
        SettingsTile(
          icon: CupertinoIcons.lock_rotation,
          title: 'Reset Password',
          subtitle: 'Change your account password',
          iconColor: CupertinoColors.systemOrange,
          titleColor: _adaptivePrimaryText(context),
          subtitleColor: _adaptiveSecondaryText(context),
          backgroundColor: _adaptiveSecondaryBackground(context),
          separatorColor: _adaptiveSeparator(context),
          onTap: _showResetPasswordDialog,
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return SettingsSection(
      title: 'Preferences',
      backgroundColor: _adaptiveSecondaryBackground(context),
      titleColor: _adaptiveSecondaryText(context),
      children: [
        SettingsTile(
          icon: CupertinoIcons.moon_fill,
          title: 'Dark Mode',
          subtitle: 'Enable dark appearance',
          iconColor: CupertinoColors.systemIndigo,
          titleColor: _adaptivePrimaryText(context),
          subtitleColor: _adaptiveSecondaryText(context),
          backgroundColor: _adaptiveSecondaryBackground(context),
          separatorColor: _adaptiveSeparator(context),
          trailing: CupertinoSwitch(
            value: isDarkMode,
            onChanged: _toggleDarkMode,
          ),
        ),
        SettingsTile(
          icon: CupertinoIcons.bell_fill,
          title: 'Notifications',
          subtitle: 'Push notifications and alerts',
          iconColor: CupertinoColors.systemRed,
          titleColor: _adaptivePrimaryText(context),
          subtitleColor: _adaptiveSecondaryText(context),
          backgroundColor: _adaptiveSecondaryBackground(context),
          separatorColor: _adaptiveSeparator(context),
          onTap: _handleNotifications,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: 'About',
      backgroundColor: _adaptiveSecondaryBackground(context),
      titleColor: _adaptiveSecondaryText(context),
      children: [
        SettingsTile(
          icon: CupertinoIcons.info_circle_fill,
          title: 'About Mama\'s Recipes',
          subtitle: 'Version 1.0.0',
          iconColor: CupertinoColors.systemGreen,
          titleColor: _adaptivePrimaryText(context),
          subtitleColor: _adaptiveSecondaryText(context),
          backgroundColor: _adaptiveSecondaryBackground(context),
          separatorColor: _adaptiveSeparator(context),
          onTap: _showAppInfo,
        ),
        SettingsTile(
          icon: CupertinoIcons.question_circle_fill,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          iconColor: CupertinoColors.systemPurple,
          titleColor: _adaptivePrimaryText(context),
          subtitleColor: _adaptiveSecondaryText(context),
          backgroundColor: _adaptiveSecondaryBackground(context),
          separatorColor: _adaptiveSeparator(context),
          onTap: _showHelpSupport,
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return SettingsSection(
      title: '',
      backgroundColor: _adaptiveSecondaryBackground(context),
      titleColor: _adaptiveSecondaryText(context),
      children: [
        SettingsTile(
          icon: CupertinoIcons.square_arrow_right,
          title: 'Logout',
          iconColor: CupertinoColors.systemRed,
          titleColor: _adaptivePrimaryText(context),
          backgroundColor: _adaptiveSecondaryBackground(context),
          separatorColor: _adaptiveSeparator(context),
          isDestructive: true,
          onTap: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    if (title.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? CupertinoColors.systemOrange.withOpacity(
                  0.8,
                ) // Orange tint in dark mode
              : const Color(0xFF8B4513), // Brown tint in light mode
        ),
      ),
    );
  }

  // Main UI build
  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Container(
        // CORRECTED GRADIENT TO MATCH HOME PAGE EXACTLY
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1C1C1E),
                    const Color(0xFF3D2914), // Darker orange - SAME AS HOME
                    const Color(0xFF2C1810), // Medium orange - SAME AS HOME
                    const Color(0xFF1C1C1E),
                  ]
                : [
                    const Color(0xFFFFF8F0), // Light cream - SAME AS HOME
                    const Color(0xFFFFE5CC), // Light orange - SAME AS HOME
                    const Color(0xFFFFF0E6), // Very light orange - SAME AS HOME
                    CupertinoColors.white, // SAME AS HOME
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0], // SAME STOPS AS HOME
          ),
        ),
        child: CupertinoPageScaffold(
          backgroundColor: const Color(0x00000000), // Transparent
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'Settings',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.white
                    : const Color(
                        0xFF2C1810,
                      ), // Darker text for better contrast
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(
              0x00000000,
            ), // Transparent navigation bar
            border: null, // Remove border to blend with gradient
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 20),
                    _buildUserProfile(),
                    _buildSectionTitle('Account'),
                    _buildAccountSettings(),
                    _buildSectionTitle('Preferences'),
                    _buildPreferences(),
                    _buildSectionTitle('About'),
                    _buildAboutSection(),
                    const SizedBox(height: 20),
                    _buildLogoutSection(),
                    const SizedBox(height: 40),
                  ],
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: isDarkMode
                        ? const Color(0xFF1C1C1E).withOpacity(0.8)
                        : const Color(0xFFF8F8F8).withOpacity(0.8),
                    child: const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom SettingsSection widget to handle dark mode
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? titleColor;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.children,
    this.backgroundColor,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12), // More rounded corners
        // ADD SUBTLE SHADOW AND BORDER
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
