import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:vendscape/providers/auth_provider.dart';
import 'package:vendscape/screens/home_screen.dart';
import 'package:vendscape/screens/welcome_screen.dart';
// import 'package:vendscape/screens/onboarding_screen.dart';
// import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.lightBlue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Timer(
        Duration(
          seconds: 3,
        ), () {
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user == null) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => WelcomeScreen(),
          ));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('images/logo.png'),
          Text('Your Local Vendor Store',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ],
      )),
    );
  }
}
