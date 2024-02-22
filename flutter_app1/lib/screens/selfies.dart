import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';

import 'package:fluttertoast/fluttertoast.dart';

class PersonsPage extends StatefulWidget {
  final String name;

  // Constructor to receive the user ID from the login page
  PersonsPage({Key? key, required this.name}) : super(key: key);


  @override
  _PersonsPageState createState() => _PersonsPageState();
}

class _PersonsPageState extends State<PersonsPage> {

  List<String> persons = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse('http://192.168.132.76:9500/unique_persons/${widget.name}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        persons = List<String>.from(data);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Persons'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageFetcherPage(nextperson: persons[index],id: widget.name,)));
                // Handle button tap action here
              },
              child: Text(persons[index]),
            ),
          );
        },
      ),
    );
  }
}









































class ImageFetcherPage extends StatefulWidget {
  String nextperson;
  final String id;


  ImageFetcherPage({Key? key, required this.nextperson,required this.id}) : super(key: key);

  @override
  _ImageFetcherPageState createState() => _ImageFetcherPageState();
}

class _ImageFetcherPageState extends State<ImageFetcherPage> {


  List<String> _imageUrls = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final response = await http.get(Uri.parse('http://192.168.132.76:9500/images/${widget.id}/${widget.nextperson}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _imageUrls = List<String>.from(data['images']);
        _loading = false;
      });
    } else {
      print('Failed to load images');
    }
  }





  Future<void> _downloadAllImages() async {
    for (var imageUrl in _imageUrls) {
      try {
        await _downloadImage(imageUrl);
      } catch (e) {
        // Handle the exception, if any
        print(e);
      }
    }
    Fluttertoast.showToast(
      msg: "All images downloaded successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  void _shareAllImages() {
    try {
      String message = 'Images:\n';
      for (var imageUrl in _imageUrls) {
        message += imageUrl + '\n';
      }
      // Share the image URLs
      Share.share(message);
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "Error sharing images",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Images for ${widget.id}'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsDialog(context);
            },
          ),
        ],
      ),

      body: _loading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showEnlargedImage(context, _imageUrls[index]);
            },
              onLongPress: () {
            _showImageOptions(context, _imageUrls[index]);
          },
          child: Image.network(_imageUrls[index]),
          );
          },

      ),
    );
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }
  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Options"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download All Images'),
                  onTap: () {
                    _downloadAllImages();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share All Images'),
                  onTap: () {
                    _shareAllImages();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


void _showImageOptions(BuildContext context, String imageUrl) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share Image'),
              onTap: () {
                _shareImage(imageUrl);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Download Image'),
              onTap: () {
                _downloadImage(imageUrl);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _shareImage(String imageUrl) {
  Share.share(imageUrl);
}

Future<void> _downloadImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String filePath = '${appDirectory.path}/${Uri.parse(imageUrl).pathSegments.last}';
    final File imageFile = File(filePath);

    await imageFile.writeAsBytes(response.bodyBytes);
    Fluttertoast.showToast(
      msg: " Image downloaded successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } else {
    print('Failed to download image');
    throw Exception('Failed to download image');
  }
}





