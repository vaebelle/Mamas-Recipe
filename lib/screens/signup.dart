import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/screens/login.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/screens/home.dart';

class Signup extends StatefulWidget {
  Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
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
          title: const Text('Password Requirements'),
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
              child: const Text('OK'),
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
      await authService.value.createAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'An account already exists with this email address';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled';
            break;
          default:
            errorMessage = e.message ?? "Sign up failed";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "An unexpected error occurred";
      });
    }
  }

  void signInWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final userCredential = await authService.value.loginWithGoogle();

      if (userCredential != null && mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      } else if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage =
              'Google sign-in was cancelled or failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Google Sign In Failed: ${e.toString()}';
      });
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  Icon(
                    CupertinoIcons.person_add_solid,
                    size: 50,
                    color: isDarkMode
                        ? const Color(0xFFAEAEB2)
                        : CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Mama's Recipes",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
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
                                  final isValid =
                                      validation[req['key']] as bool;
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
                                    color: CupertinoColors.systemBlue,
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
                  ),

                  const SizedBox(height: 20),

                  Button(
                    onTap: isLoading ? null : signInWithGoogle,
                    text: isLoading ? "Loading..." : "Sign up with Google",
                    borderRadius: 20.0,
                    color: CupertinoColors.white,
                    textColor: CupertinoColors.black,
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                      width: 1.0,
                    ),
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
                              builder: (BuildContext context) => Login(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: CupertinoColors.systemBlue),
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
