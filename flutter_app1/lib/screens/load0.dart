import 'package:flutter/material.dart';

import 'package:flutter_app1/screens/load1.dart';

class Loading0 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/spl.jpg'), // Replace with your image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20), // Adjust the spacing between image and text
              // Text 1
              Text(
                'Easy and Safe \n File Storage',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20), // Adjust the spacing between text 1 and text 2
              // Text 2
              Text(
                'Store your files with us\nand share anytime',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20), // Adjust the spacing between text 2 and button
              // Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>Loading1(),
                      ),
                    );
                    // Handle button press
                  },
                  style: ButtonStyle(

                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(

                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  child:Padding(padding:EdgeInsets.symmetric(horizontal:115),
                    child: Text('Get Started',style:TextStyle(fontSize:20)),

                  ) ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
