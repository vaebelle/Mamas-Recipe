import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/screens/login.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() {}

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
                CustomTextField(
                  controller: usernameController,
                  hintText: "Name",
                  obscureText: false,
                ),

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
                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),

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
