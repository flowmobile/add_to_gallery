# Add to Gallery

## Credits

Add to Gallery is based on [gallery_saver](https://pub.dev/packages/gallery_saver) with some notable differences:

<table>
  <tr>
    <th>Feature</th>
    <th>add_to_gallery - <em>this package</em></th>
    <th>[gallery_saver](https://pub.dev/packages/gallery_saver)</th>
  </tr>
  <tr>
    <th>Return Formats</th>
    <td>
      <ul>
        <li>Returns <code>bool</code> for the success of the operation.</li>
        <li>This is problematic on Android. The file is <strong>copied</strong> to a new location. There's no way to know the new path.</li>
        <li>This is OK on iOS. The file keeps the same URI. <em>Think of it like a shortcut being added to the gallery</em>.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Returns the <code>path</code> of the file in the gallery.</li>
        <li>Android and iOS now behave in the same way.</li>
        <li>The file is copied to a new, public location, the path is returned.</li>
        <li>You are free to delete your source file after the operation.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Temporary Files</th>
    <td>
      <ul>
        <li>Unopinionated about temporary files.</li>
        <li>Not a problem on Android as the file is copied (see above).</li>
        <li>On iOS, there's no guarantee that a temporary file will not be deleted.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Always copies files to <code>getApplicationDocumentsDirectory</code> for persistence.</li>
        <li>Always returns a new file path (see above).</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Remote Files (over http)</th>
    <td>
      <ul>
        <li>Automatically downloads files that start with <strong>http</strong>.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Does not download files that start with <strong>http</strong>.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Album Name</th>
    <td>
      <ul>
        <li>Optional with default values.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Is required.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Image Manipulation</th>
    <td>
      <ul>
        <li>(Android) Automatically rotates images according to EXIF data.</li>
        <li>(Android) Thumbnails are created (this is deprecated behaviour).</li>
        <li>(iOS) Does not manipulate images.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Does not manipulate images.</li>
      </ul>
    </td>
  </tr>
</table>

# TODO

  addToGallery
    Bool deleteOriginal

This package does too much:

Review my @TODOs
Review Permissions
  I think the first call on iOS fails
Be a little smarter about temporary files
  Android seems to WRITE a new file
  iOS needs review
Review `files.dart`
Video in README

Review CHANGELOG, contributing and README
Documentation
  Needs a lot of work
  Important NOTE
    Google Photos will automatically remove exact duplicate images
    which can cause confusion

# Gallery Saver for Flutter

Saves images and videos from network or temporary file to external storage. 
Both images and videos will be visible in Android Gallery and iOS Photos.

NOTE: If you want to save network image or video link, it has to contain 'http/https' prefix.


## Installation

First, add `add_to_gallery` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS

Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called _Privacy - Photo Library Usage Description_ in the visual editor.

### Android

* `android.permission.WRITE_EXTERNAL_STORAGE` - Permission for usage of external storage

### Example

``` dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';
  double textSize = 20;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(
                child: SizedBox.expand(
                  child: RaisedButton(
                    color: Colors.blue,
                    onPressed: _takePhoto,
                    child: Text(firstButtonText,
                        style:
                            TextStyle(fontSize: textSize, color: Colors.white)),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(
                  child: SizedBox.expand(
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: _recordVideo,
                  child: Text(secondButtonText,
                      style: TextStyle(
                          fontSize: textSize, color: Colors.blueGrey)),
                ),
              )),
              flex: 1,
            )
          ],
        ),
      ),
    ));
  }

  void _takePhoto() async {
    ImagePicker.pickImage(source: ImageSource.camera)
        .then((File recordedImage) {
      if (recordedImage != null && recordedImage.path != null) {
        setState(() {
          firstButtonText = 'saving in progress...';
        });
        AddToGallery.saveImage(recordedImage.path).then((String path) {
          setState(() {
            firstButtonText = 'image saved!';
          });
        });
      }
    });
  }

  void _recordVideo() async {
    ImagePicker.pickVideo(source: ImageSource.camera)
        .then((File recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        AddToGallery.saveVideo(recordedVideo.path).then((String path) {
          setState(() {
            secondButtonText = 'video saved!';
          });
        });
      }
    });
  }
  void _saveNetworkVideo() async {
    String path =
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
    AddToGallery.saveVideo(path).then((bool success) {
      setState(() {
        print('Video is saved');
      });
    });
  }

  void _saveNetworkImage() async {
    String path =
        'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';
    AddToGallery.saveImage(path).then((bool success) {
      setState(() {
        print('Image is saved');
      });
    });
  }
}
```