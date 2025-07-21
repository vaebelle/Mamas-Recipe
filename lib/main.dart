import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/screens/home.dart';
import 'package:mama_recipe/screens/login.dart';
import 'package:mama_recipe/screens/settings.dart'
    as app_settings; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:mama_recipe/screens/authentication.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mama_recipe/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  await SharedPreferencesHelper.instance.init();

  // Use the specific Firestore Settings class
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

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
      home: Authentication(), // Changed from HomePage() to Login()
      // home: app_settings.Settings(), // Changed from Login() to Settings()
    );
  }
}
