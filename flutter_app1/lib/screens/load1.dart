import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app1/screens/login_page.dart';
import 'package:flutter_app1/screens/register_page.dart';
class Loading1 extends StatefulWidget {
  const Loading1({super.key});

  @override
  State<Loading1> createState() => _Loading1State();
}

class _Loading1State extends State<Loading1> {
  bool _showLogin = true;
  Color button1Color = Colors.blue;
  Color button2Color = Colors.blue;

  void showLoginForm() {
    setState(() {
      _showLogin = true;
      button1Color = Colors.red;
      button2Color = Colors.blue;
    });
  }

  void showSignupForm() {
    setState(() {
      button1Color = Colors.blue;
      button2Color = Colors.red;
      _showLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/104.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Other Widgets on top of the background image
            Padding(
              padding: EdgeInsets.fromLTRB(0, 135, 8,
                  MediaQuery.of(context).padding.bottom + kToolbarHeight + 90),
              child: Row(

                children: [
                  // Left side with buttons
                  Container(
                    padding: EdgeInsets.only(left:4,right: 4),
                    width: MediaQuery.of(context).size.width * 0.22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(button1Color),
                          ),

                          onPressed: showLoginForm,
                          child: Text('Login'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(button2Color),
                          ),
                          onPressed: showSignupForm,
                          child: Text('Signup'),
                        ),
                      ],
                    ),
                  ),
                  // Right side with form
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(

                        image: DecorationImage(
                          image: AssetImage('assets/103.jpg'),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.purpleAccent,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _showLogin ? LoginPage() : RegistrationPage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
