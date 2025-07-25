import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/screens/signup.dart';
import 'package:mama_recipe/models/users.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoginLoading = false; // Separate loading state for login
  bool isGoogleLoading = false; // Separate loading state for Google

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signIn() async {
    setState(() {
      isLoginLoading = true; // Only set login loading
    });

    try {
      await authService.value.signIn(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // No need to manually navigate - AuthWrapper will handle this automatically
      // when the authentication state changes
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage =
                'No account found with this email address. Please sign up first.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'user-disabled':
            errorMessage =
                'This account has been disabled. Please contact support.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later.';
            break;
          default:
            errorMessage = e.message ?? 'An error occurred during sign in.';
        }

        _showErrorDialog('Login Failed', "Please try again.");
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Login Failed',
          'An unexpected error occurred: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoginLoading = false; // Reset only login loading
        });
      }
    }
  }

  void signInWithGoogle() async {
    setState(() {
      isGoogleLoading = true; // Only set Google loading
    });

    try {
      final userCredential = await authService.value.loginWithGoogle();

      if (userCredential != null && mounted) {
        // ADDED: Check if user document exists in Firestore, create if not
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Extract names from Google displayName
          final displayName = userCredential.user?.displayName ?? '';
          final names = displayName.split(' ');
          final firstName = names.isNotEmpty ? names.first : '';
          final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

          // Create Users model for Google sign-in user
          final newUser = Users(
            userId: userCredential.user!.uid,
            email: userCredential.user?.email ?? '',
            firstName: firstName,
            lastName: lastName,
            password: '', // Google users don't have passwords
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Save user data to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(newUser.toMap());
        }

        // Authentication widget will handle navigation automatically
      } else if (mounted) {
        _showErrorDialog(
          'Sign In Failed',
          'Google sign-in was cancelled or failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = authService.value.getErrorMessage(e);
        _showErrorDialog('Google Sign In Failed', errorMessage);
      }
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      if (mounted) {
        _showErrorDialog(
          'Database Error',
          'Failed to save user data: ${e.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Google Sign In Failed',
          'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false; // Reset only Google loading
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
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
            child: Center(
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

                    CustomTextField(
                      controller: usernameController,
                      hintText: "Email",
                      obscureText: false,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    // LOGIN BUTTON - Only shows loading when isLoginLoading is true
                    Button(
                      onTap: (isLoginLoading || isGoogleLoading)
                          ? null
                          : signIn,
                      text: isLoginLoading ? "Loading..." : "Login",
                      color: CupertinoColors.systemOrange,
                    ),

                    const SizedBox(height: 20),

                    // GOOGLE BUTTON - Only shows loading when isGoogleLoading is true
                    Button(
                      onTap: (isLoginLoading || isGoogleLoading)
                          ? null
                          : signInWithGoogle,
                      text: isGoogleLoading
                          ? "Loading..."
                          : "Continue with Google",
                      iconPath: 'assets/icons/google.png',
                      borderRadius: 20.0,
                      color: CupertinoColors.white,
                      textColor: CupertinoColors.black,
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1.0,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ACTIVITY INDICATOR - Shows when either button is loading
                    if (isLoginLoading || isGoogleLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CupertinoActivityIndicator(),
                      ),

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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
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
                          "Don't have an account? ",
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
                                builder: (BuildContext context) =>
                                    const Signup(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: CupertinoColors.systemOrange,
                            ),
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
      ),
    );
  }
}
