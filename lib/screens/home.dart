import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/textfield.dart';
import 'package:mama_recipe/widgets/button.dart';

final searchController = TextEditingController();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: navigationBar(),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              controller: searchController,
              hintText: "Search recipe",
              obscureText: false,
              borderRadius: 13.0,
              pathName: "assets/icons/search.svg",
            ),
          ],
        ),
      ),
    );
  }

  CupertinoNavigationBar navigationBar() {
    return const CupertinoNavigationBar(
      middle: Text(
        'Mama\'s Recipes',
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: CupertinoColors.white,
      border: null,
    );
  }
}
