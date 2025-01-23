import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Function to check the authentication status
  Future<void> _checkUserStatus() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Simulate a loading delay

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is logged in, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // If the user is not logged in, navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image for the splash screen (ensure the logo is correctly placed in assets)
            Image.asset('assets/images/Blood Donation Logo.png',
                width: 600, height: 600),
            const SizedBox(height: 100),
            //const CircularProgressIndicator(), // Loading indicator while waiting
          ],
        ),
      ),
    );
  }
}
