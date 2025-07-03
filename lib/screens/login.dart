import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/screens/signup.dart';
import 'package:mama_recipe/screens/home.dart'; // Import your home page

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await authService.value.signIn(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to home page on successful login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: Text('Error: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await authService.value.loginWithGoogle();

      if (userCredential != null && mounted) {
        // Navigate to home page on successful Google sign-in
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      } else if (mounted) {
        // Show error if sign-in failed or was cancelled
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sign In Failed'),
            content: const Text(
              'Google sign-in was cancelled or failed. Please try again.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Google Sign In Failed'),
            content: Text('Error: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // logo
                const Icon(
                  CupertinoIcons.lock_fill,
                  size: 50,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Mama's Recipes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Share your culinary creations",
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),

                const SizedBox(height: 50),

                // username textfield
                CustomTextField(
                  controller: usernameController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // password textfield
                CustomTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                // login button
                Button(
                  onTap: isLoading ? null : signIn,
                  text: isLoading ? "Loading..." : "Login",
                ),

                const SizedBox(height: 20),

                //sign in with google
                Button(
                  onTap: isLoading ? null : signInWithGoogle,
                  text: isLoading ? "Loading..." : "Sign in with Google",
                  borderRadius: 20.0,
                  color: CupertinoColors.white,
                  textColor: CupertinoColors.black,
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 1.0,
                  ),
                ),

                const SizedBox(height: 40),

                // Show loading indicator
                if (isLoading)
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
                          color: CupertinoColors.systemGrey3,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          'OR',
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: CupertinoColors.systemGrey3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                //sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (BuildContext context) => Signup(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
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
    );
  }
}
