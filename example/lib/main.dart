import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:add_to_gallery/add_to_gallery.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final String _albumName = 'Add to Gallery';

double textSize = 20;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            Text(
              'Add to Gallery',
              style: Theme.of(context).textTheme.headline3,
            ),
            SaveAsset(assetPath: 'assets/local-image-1.jpg'),
            SaveAsset(assetPath: 'assets/local-image-2.jpg'),
            /*
            Flexible(
              flex: 1,
              child: Container(
                child: SizedBox.expand(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: _takePhoto,
                    child: Text(firstButtonText,
                        style: TextStyle(
                            fontSize: textSize, color: Colors.white)),
                  ),
                ),
              ),
            ),
            ScreenshotWidget(),
            Flexible(
              child: Container(
                  child: SizedBox.expand(
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: _recordVideo,
                  child: Text(secondButtonText,
                      style: TextStyle(
                          fontSize: textSize, color: Colors.blueGrey)),
                ),
              )),
              flex: 1,
            ),
            */
          ],
        ),
      ),
    );
  }
  /*
  void _takePhoto() async {
    ImagePicker()
        .getImage(source: ImageSource.camera)
        .then((PickedFile recordedImage) {
      if (recordedImage != null && recordedImage.path != null) {
        setState(() {
          firstButtonText = 'saving in progress...';
        });
        AddToGallery.saveImage(recordedImage.path, albumName: _albumName)
            .then((dynamic filePath) {
          print(filePath);
          setState(() {
            firstButtonText = 'image saved!';
          });
        });
      }
    });
  }

  void _recordVideo() async {
    ImagePicker()
        .getVideo(source: ImageSource.camera)
        .then((PickedFile recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        AddToGallery.saveVideo(recordedVideo.path, albumName: _albumName)
            .then((dynamic filePath) {
          print(filePath);
          setState(() {
            secondButtonText = 'video saved!';
          });
        });
      }
    });
  }
  */
}

class SaveAsset extends StatelessWidget {
  final String assetPath;

  const SaveAsset({
    Key? key,
    required this.assetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          try {
            File file = await _copyAssetLocally(assetPath);
            String path = await AddToGallery.addToGallery(
              originalFile: file,
              albumName: _albumName,
              deleteOriginalFile: false, // It's in a temp directory anyhow
            );
            // TODO: show this in the UI
            // print('originalPath: ${file.path}');
            // print('path: $path');
            await _showAlertMessage(context, 'Asset saved with path: $path');
          } on PlatformException catch (e) {
            await _showAlertMessage(context, 'Error: ${e.message}');
          } catch (e) {
            await _showAlertMessage(context, 'Error: ${e.toString()}');
          }
        },
        child: Column(
          children: <Widget>[
            Image.asset(
              assetPath,
              height: 200,
            ),
            Text('Save Local Asset'),
          ],
        ),
      ),
    );
  }
}

//
Future<void> _showAlertMessage(
  BuildContext context,
  String message,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Saved to Gallery'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

// Saves an asset
Future<File> _copyAssetLocally(
  String path,
) async {
  ByteData byteData = await rootBundle.load(path);
  File file = await _getBlankFileForAsset(
    path: path,
    prefix: 'assets',
  );
  await file.writeAsBytes(
    byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    ),
  );
  return file;
}

// Returns a writeable file for a path
Future<File> _getBlankFileForAsset({
  required String path,
  required String prefix,
}) async {
  String fileExt = extension(path);
  int now = DateTime.now().millisecondsSinceEpoch;
  String fileName = '$prefix-$now$fileExt';
  Directory directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/$fileName');
}
