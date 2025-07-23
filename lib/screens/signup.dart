import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/screens/login.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/screens/authentication.dart';
import 'package:mama_recipe/models/users.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // FIXED: Separate controllers for each field
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String errorMessage = "";
  bool isLoading = false;
  bool _showPasswordHints = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      setState(() {
        _showPasswordHints = passwordController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    passwordController.removeListener(() {});
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Map<String, bool> _getPasswordValidation(String password) {
    return {
      'length': password.length >= 6,
      'uppercase': password.contains(RegExp(r'[A-Z]')),
      'lowercase': password.contains(RegExp(r'[a-z]')),
      'number': password.contains(RegExp(r'[0-9]')),
      'special': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }

  void _showPasswordRequirements() {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text(
            'Password Requirements',
            style: TextStyle(color: CupertinoColors.systemOrange),
          ),
          content: const Text(
            'Password must contain:\n\n'
            '• At least 6 characters\n'
            '• At least one uppercase letter (A-Z)\n'
            '• At least one lowercase letter (a-z)\n'
            '• At least one number (0-9)\n'
            '• At least one special character (!@#\$%^&*)\n'
            '• Maximum 4096 characters',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'OK',
                style: TextStyle(color: CupertinoColors.systemOrange),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void signUp() async {
    setState(() {
      errorMessage = "";
      isLoading = true;
    });

    // ADDED: Basic validation for all fields
    if (firstNameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter your first name";
        isLoading = false;
      });
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter your last name";
        isLoading = false;
      });
      return;
    }

    if (emailController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter your email address";
        isLoading = false;
      });
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter a password";
        isLoading = false;
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Passwords do not match";
        isLoading = false;
      });
      return;
    }

    final validation = _getPasswordValidation(passwordController.text);
    final isPasswordValid = validation.values.every((isValid) => isValid);

    if (!isPasswordValid) {
      setState(() {
        errorMessage = "Please ensure your password meets all requirements";
        isLoading = false;
      });
      return;
    }

    try {
      // Create the Firebase Auth account
      final userCredential = await authService.value.createAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Set the display name in Firebase Auth
        final displayName =
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
        await userCredential.user!.updateDisplayName(displayName);

        // Reload the user to get the updated display name
        await userCredential.user!.reload();

        // ADDED: Create Users model and save to Firestore
        final newUser = Users(
          userId: userCredential.user!.uid,
          email: emailController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          password: '', // Don't store actual password for security
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        if (mounted) {
          // Clear form fields
          firstNameController.clear();
          lastNameController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();

          // FIXED: Navigate to Authentication widget instead of directly to HomePage
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => const Authentication()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          // Use the auth service's error message handler for consistency
          errorMessage = authService.value.getErrorMessage(e);
        });
      }
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to save user data: ${e.message}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "An unexpected error occurred. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping on background
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                Image.asset(
                  'assets/icons/mama_recipe_icon.png',
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 20),

                Text(
                  "Mama's Recipes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemOrange,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Share your culinary creations",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? const Color(0xFFAEAEB2)
                        : CupertinoColors.systemGrey,
                  ),
                ),

                const SizedBox(height: 50),

                // FIXED: Use firstNameController
                CustomTextField(
                  controller: firstNameController,
                  hintText: "First Name",
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // FIXED: Use lastNameController
                CustomTextField(
                  controller: lastNameController,
                  hintText: "Last Name",
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // FIXED: Keep emailController for email field
                CustomTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                Column(
                  children: [
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),

                    if (_showPasswordHints &&
                        passwordController.text.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 10.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2C2C2E)
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: isDarkMode
                                ? const Color(0xFF38383A)
                                : CupertinoColors.systemGrey4,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Requirements:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? const Color(0xFFAEAEB2)
                                    : CupertinoColors.systemGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(() {
                              final validation = _getPasswordValidation(
                                passwordController.text,
                              );
                              final requirements = [
                                {
                                  'key': 'length',
                                  'text': 'At least 6 characters',
                                },
                                {
                                  'key': 'uppercase',
                                  'text': 'One uppercase letter',
                                },
                                {
                                  'key': 'lowercase',
                                  'text': 'One lowercase letter',
                                },
                                {'key': 'number', 'text': 'One number'},
                                {
                                  'key': 'special',
                                  'text': 'One special character',
                                },
                              ];

                              return requirements.map<Widget>((req) {
                                final isValid = validation[req['key']] as bool;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isValid
                                            ? CupertinoIcons
                                                  .checkmark_circle_fill
                                            : CupertinoIcons.circle,
                                        size: 14,
                                        color: isValid
                                            ? CupertinoColors.systemGreen
                                            : CupertinoColors.systemGrey3,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        req['text'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isValid
                                              ? CupertinoColors.systemGreen
                                              : (isDarkMode
                                                    ? const Color(0xFFAEAEB2)
                                                    : CupertinoColors
                                                          .systemGrey),
                                          fontWeight: isValid
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            })(),
                          ],
                        ),
                      ),

                    if (!_showPasswordHints) const SizedBox(height: 5),
                    if (!_showPasswordHints)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: GestureDetector(
                              onTap: _showPasswordRequirements,
                              child: const Text(
                                "Password Requirements",
                                style: TextStyle(
                                  color: CupertinoColors.systemOrange,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                if (errorMessage.isNotEmpty &&
                    !errorMessage.contains('Password must contain'))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            size: 16,
                            color: CupertinoColors.systemRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                Button(
                  onTap: isLoading ? null : signUp,
                  text: isLoading ? "Loading..." : "Sign Up",
                  color: CupertinoColors.systemOrange,
                ),

                const SizedBox(height: 20),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoActivityIndicator(),
                  ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: isDarkMode
                              ? const Color(0xFF38383A)
                              : CupertinoColors.systemGrey3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFFAEAEB2)
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: isDarkMode
                              ? const Color(0xFF38383A)
                              : CupertinoColors.systemGrey3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: isDarkMode
                            ? const Color(0xFFAEAEB2)
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (BuildContext context) => const Login(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: CupertinoColors.systemOrange),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
