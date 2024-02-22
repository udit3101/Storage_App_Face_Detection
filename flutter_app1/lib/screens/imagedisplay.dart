import 'dart:convert';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart'; // Import the share plugin

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageDisplayPage extends StatefulWidget {
  final List<String> images;

  ImageDisplayPage({required this.images});

  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Display'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showImageDialog(widget.images[index]);
            },
            onLongPress: () {
              _showOptionsDialog(widget.images[index]);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  base64Decode(widget.images[index]),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 16.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          'IMAGE',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

    );
  }

  Future<void> _showImageDialog(String base64Image) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.memory(
            base64Decode(base64Image),
          ),
        );
      },
    );
  }

  Future<void> _showOptionsDialog(String base64Image) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.file_download),
                title: Text('Download'),
                onTap: () {
                  Navigator.of(context).pop();
                  _downloadImage(base64Image);
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareImage(base64Image);
                },
              ),
            ],
          ),
        );
      },
    );
  }





  void _downloadImage(String base64Image) async {
    try {
      // Decode base64 to bytes
      List<int> bytes = base64Decode(base64Image);

      // Get the external storage directory using path_provider
      Directory? externalDirectory = await getExternalStorageDirectory();

      if (externalDirectory != null) {
        // Create a directory named "flutter" in the external storage
        Directory directory =
        await Directory('${externalDirectory.path}/flutter').create();

        // Create a file with a unique name (e.g., using DateTime)
        String fileName =
            'image_${DateTime.now().millisecondsSinceEpoch}.png';
        File file = File('${directory.path}/$fileName');

        // Write the bytes to the file
        await file.writeAsBytes(bytes);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image downloaded successfully to ${file.path}'),
          ),
        );
      } else {
        print('Error: External storage directory is null');
      }
    } catch (error) {
      print('Error downloading image: $error');
      // Show an error message if needed
    }
  }

  void _shareImage(String base64Image) async {
    try {
      // Decode base64 to bytes
      List<int> bytes = base64Decode(base64Image);

      // Create a temporary file to share
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File('${tempDir.path}/temp_image.png').create();
      await tempFile.writeAsBytes(bytes);

      // Share the image file
      Share.shareFiles([tempFile.path]);
    } catch (error) {
      print('Error sharing image: $error');
      // Show an error message if needed
    }
  }
}
