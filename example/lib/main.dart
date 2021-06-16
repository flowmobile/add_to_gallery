import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final String _albumName = 'Gallery Saver';

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
        GallerySaver.saveImage(recordedImage.path, albumName: _albumName)
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
        GallerySaver.saveVideo(recordedVideo.path, albumName: _albumName)
            .then((dynamic filePath) {
          print(filePath);
          setState(() {
            secondButtonText = 'video saved!';
          });
        });
      }
    });
  }

  // ignore: unused_element
  void _saveNetworkVideo() async {
    String path =
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
    GallerySaver.saveVideo(path, albumName: _albumName)
        .then((dynamic filePath) {
      print(filePath);
      setState(() {
        print('Video is saved');
      });
    });
  }

  // ignore: unused_element
  void _saveNetworkImage() async {
    String path =
        'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';
    GallerySaver.saveImage(path, albumName: _albumName)
        .then((dynamic filePath) {
      print(filePath);
      setState(() {
        print('Image is saved');
      });
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
            File file = await _saveAsset(assetPath);
            String path = await GallerySaver.saveImage(
              file.path,
              albumName: _albumName,
            );
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
Future<File> _saveAsset(
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

/*
class ScreenshotWidget extends StatefulWidget {
  @override
  _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  final GlobalKey _globalKey = GlobalKey();
  String screenshotButtonText = 'Save screenshot';

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
          child: SizedBox.expand(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink),
              ),
              onPressed: _saveScreenshot,
              child: Text(screenshotButtonText,
                  style: TextStyle(fontSize: textSize, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveScreenshot() async {
    setState(() {
      screenshotButtonText = 'saving in progress...';
    });
    try {
      //extract bytes
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      //create file
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String fullPath = '$dir/${DateTime.now().millisecond}.png';
      File capturedFile = File(fullPath);
      await capturedFile.writeAsBytes(pngBytes);

      await GallerySaver.saveImage(capturedFile.path, albumName: _albumName)
          .then((dynamic filePath) {
        print(filePath);
        setState(() {
          screenshotButtonText = 'screenshot saved!';
        });
      });
    } catch (e) {
      print(e);
    }
  }
}
*/
