import 'package:flutter/material.dart';
import 'package:flutter_app1/screens/load1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app1/screens/home_page.dart';
import 'package:flutter_app1/screens/login_page.dart';
import 'package:flutter_app1/screens/load0.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getString('token') != null;

    // Simulate loading time for the splash screen
    await Future.delayed(Duration(seconds: 2));

    if (isLoggedIn) {
      String email = prefs.getString('email') ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userid: email),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>Loading0(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.grey, Colors.black87],
                begin: const FractionalOffset(0.0, 1.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.repeated)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("hello buddy")
            ],
          ),
        ),
      )
    );
  }
}


