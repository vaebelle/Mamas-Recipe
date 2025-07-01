import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // logo
              const Icon(Icons.lock, size: 50),
              const SizedBox(height: 20),

              const Text(
                "Mama's Recipes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Share your culinary creations",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 50),

              // username textfield
              CustomTextField(
                controller: usernameController,
                hintText: "Email",
                obscureText: false,
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
              //   child: TextField(
              //     decoration: InputDecoration(
              //       labelText: "Email",
              //       contentPadding: const EdgeInsets.symmetric(
              //         horizontal: 12.0,
              //         vertical: 8.0,
              //       ),
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: const BorderSide(color: Colors.grey),
              //         borderRadius: BorderRadius.circular(12.0),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: Colors.grey.shade700),
              //         borderRadius: BorderRadius.circular(12.0),
              //       ),
              //       fillColor: Colors.grey.shade200,
              //       filled: true,
              //     ),
              //   ),
              // ),
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
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey.shade600,
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
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Signup(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
