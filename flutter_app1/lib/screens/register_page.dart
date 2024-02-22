import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app1/screens/imageselection.dart';
import 'package:flutter_app1/screens/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:http_parser/http_parser.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  DateTime? selectedDate; // Added for DOB

  File? _image;

  Future<void> registerUser() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String phone = phoneController.text;
    final String password = passwordController.text;

    // Format selected date to a string (if available)
    final String dob = selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '';

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || _image == null || dob.isEmpty) {
      // Show an error message or alert if any field is empty
      // For simplicity, we'll just print an error message for now
      print('All fields are compulsory');
      return;
    }

    final String url = 'http://192.168.132.76:3000/register';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields['name'] = name
      ..fields['email'] = email
      ..fields['phone'] = phone
      ..fields['password'] = password
      ..fields['dob'] = dob; // Include DOB in the request

    if (_image != null) {
      final http.MultipartFile imageFile = await http.MultipartFile.fromPath(
        'profile_pic',
        _image!.path,
        contentType: MediaType('image', 'jpg'),
      );
      request.files.add(imageFile);
    }

    try {
      final http.Response response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 201) {
        print('User registered successfully');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ImageSelectionScreen(userid: emailController.text.toString(),)));
        // Handle navigation or any other action on successful registration
      } else {
        print('Failed to register user. Error: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error during registration: $error');
      // Handle the error accordingly
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

             Column(
               children:[
                 Text(
                   'Signup',
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                 ),
                 SizedBox(height: 30.0),
                 GestureDetector(
                   onTap: _getImage,
                   child: CircleAvatar(
                     radius: 50,
                     backgroundColor: Colors.blue,
                     child: _image != null
                         ? ClipOval(
                       child: Image.file(
                         _image!,
                         fit: BoxFit.cover,
                         width: 100,
                         height: 100,
                       ),
                     )
                         : Icon(
                       Icons.camera_alt,
                       size: 50,
                       color: Colors.white,
                     ),
                   ),
                 ),


                 SizedBox(height: 16),

                 // Text field to display and pick DOB
                 TextFormField(
                   controller: dobController,
                   readOnly: true,
                   onTap: () => _selectDate(context),
                   decoration: InputDecoration(labelText: 'DOB', border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(25),
                   )),
                 ),

                 SizedBox(height: 12),

                 //Your text fields
                 TextField(controller: nameController, decoration: InputDecoration(labelText: 'Username', border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(25),
                 ))),
                 SizedBox(height: 12),
                 TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(25),
                 ))),
                 SizedBox(height: 12),
                 TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(25),
                 ))),
                 SizedBox(height: 12),
                 TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(25),
                 ))),

               ]
             ),

              // Button to register user
              ElevatedButton(
                onPressed: registerUser,
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
                    child: Text('SignUp',style:TextStyle(fontSize:20)),

                  ),
              ),
            ],
          ),
        ),

    );
  }
}