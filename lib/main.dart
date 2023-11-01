import 'package:driver_app/Location.dart';
import 'package:driver_app/dashboard.dart';
import 'package:driver_app/newLocation.dart';
import 'package:driver_app/signUp.dart';
import 'package:driver_app/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ForgotPassword.dart';
import 'logIn.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  runApp(ProviderScope(child: MyApp(email: email)));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.email});
  final email;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: widget.email == null ? SplashScreen() : Dashboard(),
    );
  }
}
