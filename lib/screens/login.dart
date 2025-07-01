import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';
import 'package:mama_recipe/screens/signup.dart';

class Login extends StatelessWidget {
  Login({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() {}

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
                Button(onTap: signIn, text: "Login"),

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
