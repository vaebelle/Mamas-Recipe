import 'package:flutter/material.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';

final searchController = TextEditingController();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
            CustomTextField(
                controller: searchController,
                hintText: "Search recipe",
                obscureText: false,
                borderRadius: 13.0,
                pathName: "assets/icons/search.svg",
              ),
              ]
            ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Mama\'s Recipes',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
    );
  }
}

