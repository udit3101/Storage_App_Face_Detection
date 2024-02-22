import 'package:flutter/material.dart';
import 'package:flutter_app1/screens/register_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    final String apiUrl = 'http://192.168.132.76:3000/login';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      print('Login successful: ${data['message']}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', 'your_user_token_here');
      prefs.setString('email', emailController.text); // Store user email

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userid: emailController.text.toString()),
        ),
      );
    } else if (response.statusCode == 401) {
      Map<String, dynamic> data = json.decode(response.body);
      print('Error: ${data['error']}');
    } else {
      print('Internal Server Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children:[
                Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email',border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  )),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  )),
                  obscureText: true,
                ),

              ]
            ),

            ElevatedButton(
              onPressed: () => loginUser(context),
    style: ButtonStyle(

    shape: MaterialStateProperty.all(
    RoundedRectangleBorder(

    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(25),
    topRight: Radius.circular(25),
    bottomLeft: Radius.circular(25),
    bottomRight: Radius.circular(25),
    ),
    ),
    ),
    ),

    child:Padding(padding:EdgeInsets.symmetric(horizontal:40),
    child: Text('Login',style:TextStyle(fontSize:20)),

    )
            ),
          ],
        ),

    );
  }
}
