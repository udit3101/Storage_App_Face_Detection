import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app1/screens/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class ImageSelectionScreen extends StatefulWidget {
  final String userid;

  // Constructor to receive the user ID from the login page
  const ImageSelectionScreen({Key? key, required this.userid}) : super(key: key);

  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final picker = ImagePicker();
  List<XFile?> _images = [];
  bool _isUploading = false;

  Future getImage() async {
    if (_images.length >= 3) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Limit Reached'),
            content: Text('You can only select three images.'),
            actions: <Widget>[
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
      return;
    }
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _images.add(pickedFile);
    });
  }

  Future<void> _registerFace() async {
    try {
      if (_images.length != 3) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please select three images.'),
              actions: <Widget>[
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
        return;
      }

      setState(() {
        _isUploading = true;
      });

      var request = http.MultipartRequest('POST', Uri.parse('http://192.168.132.76:5000/post-face'));
      request.fields['label'] = widget.userid; // You can specify the label here
      for (var i = 0; i < _images.length; i++) {
        var file = await http.MultipartFile.fromPath('File${i + 1}', _images[i]!.path);
        request.files.add(file);
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        // Face data stored successfully
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userid: widget.userid)));// Go back to the homepage
        // Go back to the homepage
      } else {
        // Something went wrong
        print('Failed to register face');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Images'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: _images.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: getImage,
                    child: Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.add),
                    ),
                  );
                } else {
                  return Image.file(File(_images[index]!.path), fit: BoxFit.cover);
                }
              },
            ),
          ),
          _isUploading
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _registerFace,
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
