import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/screens/login.dart';
import 'package:mama_recipe/services/auth_service.dart';
import 'package:mama_recipe/screens/home.dart';

class Signup extends StatefulWidget {
  Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // text editing controllers
  // final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final confirmPasswordController = TextEditingController();
  String errorMessage = "";

  bool isLoading = false;

  @override
  void dispose() {
    // usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    // confirmPasswordController.dispose();
    super.dispose();
  }

  void signUp() async {
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
        errorMessage = e.message ?? "There is an error";
      });
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  // Future<void> signUp(BuildContext context) async {
  //   if (usernameController.text.trim().isEmpty) {
  //     showErrorDialog(context, "Please enter your name.");
  //     return;
  //   }

  //   if (emailController.text.trim().isEmpty) {
  //     showErrorDialog(context, "Please enter your email.");
  //     return;
  //   }

  //   if (passwordController.text.trim().isEmpty) {
  //     showErrorDialog(context, "Please enter your password.");
  //     return;
  //   }

  //   if (passwordController.text != confirmPasswordController.text) {
  //     showErrorDialog(context, "Password do not match.");
  //     return;
  //   }

  //   // TODO: Implement sign up logic here (e.g., call API, handle loading state in a StatefulWidget)
  // }

  // void showErrorDialog(BuildContext context, String message) {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (context) => CupertinoAlertDialog(
  //       title: const Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         CupertinoDialogAction(
  //           child: const Text('OK'),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGrey6,
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

                // name textfield
                // CustomTextField(
                //   controller: usernameController,
                //   hintText: "Name",
                //   obscureText: false,
                // ),
                const SizedBox(height: 20),

                // email textfield
                CustomTextField(
                  controller: emailController,
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

                // confirm password textfield
                // CustomTextField(
                //   controller: confirmPasswordController,
                //   hintText: "Confirm Password",
                //   obscureText: true,
                // ),
                const SizedBox(height: 20),

                // sign up button
                Button(onTap: signUp, text: "Sign Up"),

                const SizedBox(height: 40),

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

                //sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: CupertinoColors.systemGrey),
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
    );
  }
}
