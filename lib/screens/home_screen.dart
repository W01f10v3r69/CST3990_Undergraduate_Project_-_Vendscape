import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendscape/providers/auth_provider.dart';
import 'package:vendscape/screens/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: (){
            auth.error='';
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>WelcomeScreen(),
              ));
            });
          },
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}
