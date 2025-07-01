import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/screens/home.dart';
import 'package:mama_recipe/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      home: HomePage(),
    );
  }
}
