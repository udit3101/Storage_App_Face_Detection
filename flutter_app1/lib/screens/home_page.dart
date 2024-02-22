import 'dart:convert';
import 'package:flutter_app1/screens/self.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/screens/Getbal.dart';
import 'package:flutter_app1/screens/updatescreen.dart';
import 'package:flutter_app1/widgets/form_fields_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app1/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'imagedisplay.dart';

import 'selfies.dart';

class HomePage extends StatefulWidget{
  final String userid;

  // Constructor to receive the user ID from the login page
  const HomePage({Key? key, required this.userid}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePage>{
  String _uploadingMessage = '';
  late String userEmail;
  Uint8List? profilePicData;
  Future<void> fetchProfilePicData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.132.76:3000/getProfilePic/$userEmail'));

      if (response.statusCode == 200) {
        setState(() {
          profilePicData = response.bodyBytes;
        });
      } else {
        // Handle error
        print('Failed to fetch profile picture');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
    }
  }





  String _result = '';
  final picker = ImagePicker();
  bool _uploading = false;
  int _totalImages = 0;
  int _uploadedImages = 0;

  Future<void> _pickAndCheckFace() async {
    setState(() {
      _uploading = true;
    });

    List<XFile>? pickedImages = await picker.pickMultiImage(); // Allow multiple image selection
    if (pickedImages != null && pickedImages.isNotEmpty) {
      setState(() {
        _getTotalSize();
        _getAvlSpace();
        _totalImages = pickedImages.length;
        _uploadedImages = 0;
      });

      for (var pickedImage in pickedImages) {
        await _processImage(pickedImage.path);
      }
    } else {
      setState(() {
        _uploading = false;
      });
    }
  }
  Future<void> _processImage(String imagePath) async {
    var url = Uri.parse('http://192.168.132.76:5000/check-face'); // Replace with your server URL
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('File1', imagePath));
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);
      var result = data['result'];
      print(result);

      if (result.isEmpty) {
        await _uploadImage(imagePath);
      } else {
        var uniqueNames = Set<String>();

        // Iterate over the result to find unique names
        for (var person in result) {
          if (person != 'unknown') {
            uniqueNames.add(person);
          }
        }

        // Upload image using _uploadImage for 'unknown' only once
        if (result.contains('unknown')) {
          await _uploadImage(imagePath);

          _getTotalSize();
          _getAvlSpace();

        }

        // Upload image using _uploadSelfie for each unique name
        for (var name in uniqueNames) {
          await _uploadSelfie(imagePath, name);

          _getTotalSize();
          _getAvlSpace();
        }
      }
    } else {
      setState(() {
        _result = 'Failed to check face';
      });
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    var url = Uri.parse('http://192.168.132.76:9500/upload'); // Replace with your server URL
    var request = http.MultipartRequest('POST', url);
    request.fields['username'] = widget.userid; // Replace with your username
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        _uploadedImages++;
      });
      _getTotalSize();
      _getAvlSpace();
      if (_uploadedImages == _totalImages) {
        // All images have been uploaded
        setState(() {
          _uploading = false; // Set uploading to false
        });

        // Show "Uploaded" text for 1 second
        setState(() {
          _uploadingMessage = 'Uploaded';
        });
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _uploadingMessage = ''; // Remove the text
        });
      }
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  Future<void> _uploadSelfie(String imagePath, String person) async {
    var url = Uri.parse('http://192.168.132.76:9500/uploadSelfie'); // Replace with your server URL
    var request = http.MultipartRequest('POST', url);
    request.fields['username'] = widget.userid; // Replace with your username
    request.fields['person'] = person;
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        _uploadedImages++;
      });
      _getTotalSize();
      _getAvlSpace();
      if (_uploadedImages == _totalImages) {
        // All images have been uploaded
        setState(() {
          _uploading = false; // Set uploading to false
        });

        // Show "Uploaded" text for 1 second
        setState(() {
          _uploadingMessage = 'Uploaded';
        });
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _uploadingMessage = ''; // Remove the text
        });
      }  print('Selfie uploaded successfully for $person');
    } else {
      print('Failed to upload selfie for $person');
    }
  }



  double? _avlspace;
  double? _totalsize;

  @override
  void initState() {
    super.initState();
    _getTotalSize();
    _getAvlSpace();
    userEmail = widget.userid;

    // Fetch the profile picture data when the page loads
    fetchProfilePicData();
  }

  Future<void> _getTotalSize() async {
    final String username = widget.userid;

    if (username.isEmpty) {
      return;
    }

    final Uri apiUrl = Uri.parse('http://192.168.132.76:3000/totalsize?username=$username');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        print('Total Size Response: $data');

        if (data != null && data.containsKey('totalSize')) {
          setState(() {
            _totalsize = double.tryParse(data['totalSize'].toString());
          });
          print('Total Size: $_totalsize');
        } else {
          print('Error: Response does not contain totalsize');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _getAvlSpace() async {
    final String username = widget.userid;

    if (username.isEmpty) {
      return;
    }

    final Uri apiUrl = Uri.parse('http://192.168.132.76:3000/avlspace?email=$username');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        print('Avl Space Response: $data');

        if (data != null && data.containsKey('avlspace')) {
          setState(() {
            _avlspace = double.tryParse(data['avlspace'].toString());
          });
          print('Available Space: $_avlspace');
        } else {
          print('Error: Response does not contain avlspace');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }




  Future<String?> fetchUsername(String email) async {
    final response = await http.get(Uri.parse('http://192.168.132.76:3000/getUsername?email=$email'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['name'];
    } else {
      throw Exception('Failed to load username');
    }
  }









  @override
  Widget build(BuildContext context) {
    double progress = _avlspace != null && _totalsize != null
        ? _totalsize! / _avlspace!
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            FutureBuilder<String?>(
              future: fetchUsername(widget.userid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return DrawerHeader(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final username = snapshot.data;
                  return UserAccountsDrawerHeader(
                    accountName: Text(username ?? 'Username'), // Display the username or 'Username' if null
                    accountEmail: Text(userEmail),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: profilePicData != null ? MemoryImage(profilePicData!) : null,
                    ),
                  );
                }
              },
            ),

            ListTile(
              title: Text('Wallet'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GetBalancePage(userEmail: widget.userid)));
              },
            ),

            ListTile(onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>updatesscreen(userid: widget.userid,)));
            }, title: Text("upgrade")),

            ListTile(
              title: Text('Logout'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('email'); // Remove stored email on logout

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),


          ],
        ),
      ),
      body:SingleChildScrollView(
        child: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/38616.jpg',
                fit: BoxFit.cover,
              ),
            ),



            Column(
              children: [


                Padding(padding: EdgeInsets.fromLTRB(8, 15,8, 15),
                  child:Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(20),

                    ),
                    width: double.infinity,
                    height: 230,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: EdgeInsets.only(top: 25, left: 15, bottom: 15),
                          child: Text(
                            "Available",
                            style: TextStyle(fontSize: 38),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 12,right: 12),child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),

                          ),
                          height: 27,
                          child:LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),),
                        SizedBox(height: 7),
                        Padding(padding: EdgeInsets.only(left: 20,right: 12,top: 10),child: Text(
                          'Used Storage: ',
                          style: TextStyle(fontSize: 20.0),
                        ),),
                        Padding(padding: EdgeInsets.only(left: 12,right: 12,top: 7),child: Text(
                          ' ${_totalsize?.toStringAsFixed(4)?? '0.0000'} GB / ${_avlspace.toString()} GB',
                          style: TextStyle(fontSize: 20.0),
                        ),),





                      ],
                    ),
                  ),
                ),
















                Padding(padding: EdgeInsets.only(left: 10,right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => allImageFetcherPage(id:widget.userid)));
                        },

                        child:  Container(
                            margin: EdgeInsets.only(right: 8.0), // Adjust the spacing between containers
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),

                            ),
                            height: 90,
                            width: double.infinity,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               Padding(padding: EdgeInsets.only(left: 10),child:  Text("All",style: TextStyle(fontSize: 34),),) ,

                                Padding(padding: EdgeInsets.only(left: 10),child: Text("Uploaded by user",style: TextStyle(fontSize: 16),),) ,

                              ], )
                        )
                        ,


                      ),
                      SizedBox(height: 15,),

                      InkWell(
                        onTap: (){

                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PersonsPage(name:widget.userid)));


                        },
                        child:   Container(
                            height: 90,
                            width:double.infinity,
                            margin: EdgeInsets.only(right: 8.0), // Adjust the spacing between containers

                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),

                            ),
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.only(left: 10),child:  Text("Selfies",style: TextStyle(fontSize: 34),),) ,
                                Padding(padding: EdgeInsets.only(left: 10),child:  Text("Images of user",style: TextStyle(fontSize: 16),),) ,


                              ], )
                        ),




                      ),
                    ],
                  ),),
                SizedBox(height: 15,),

                Container(
                    height: 150,
                    width: 120,
                    child: IconButton(
                      onPressed: () {
                        if (_totalsize != null && _avlspace != null && _totalsize! < _avlspace!) {
                          _pickAndCheckFace();
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Storage Limit Reached'),
                                content: Text('You have reached the storage limit. Please delete some files to free up space.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      icon: Icon(Icons.upload),
                      iconSize: 55,
                    )

                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  _uploading ? 'Uploading $_uploadedImages of $_totalImages images...' : '$_uploadingMessage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),







              ],
            )




          ],
        )


      )
    );
  }
}




















