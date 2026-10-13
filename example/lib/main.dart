import 'dart:io';
import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String _albumName = 'Add to Gallery';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Add to Gallery',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SaveAsset(assetPath: 'assets/local-image-1.jpg'),
            SaveAsset(assetPath: 'assets/local-image-2.jpg'),
            SaveAsset(assetPath: 'assets/local-video.mp4'),
            SaveFromCamera(video: false),
            SaveFromCamera(video: true),
            LastGalleryImage(),
          ],
        ),
      ),
    );
  }
}

class LastGalleryImage extends StatelessWidget {
  const LastGalleryImage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getGalleryPath(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        String? galleryPath = snapshot.hasData ? snapshot.data : null;
        if (galleryPath == null) {
          return Text(
            'When you restart the app, the last saved item will render here',
          );
        } else {
          return _preview(galleryPath, 100);
        }
      },
    );
  }
}

class SaveAsset extends StatelessWidget {
  final String assetPath;

  const SaveAsset({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          try {
            File localFile = await _copyAssetLocally(assetPath);
            // Grant permission
            await _grantPermissions();
            // Save
            File file = await AddToGallery.addToGallery(
              originalFile: localFile,
              albumName: _albumName,
              deleteOriginalFile: true,
              keepFilename: true,
            );
            await _saveGalleryPath(file.path);
            if (!context.mounted) return;
            await _showAlertMessage(context, file.path);
          } on PlatformException catch (e) {
            if (!context.mounted) return;
            await _showError(context, 'Error: ${e.message}');
          } catch (e) {
            if (!context.mounted) return;
            await _showError(context, 'Error: ${e.toString()}');
          }
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              _isVideo(assetPath)
                  ? Icon(Icons.videocam, size: 100)
                  : Image.asset(assetPath, height: 100),
              Text(
                _isVideo(assetPath) ? 'Save Local Video' : 'Save Local Asset',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SaveFromCamera extends StatelessWidget {
  final bool video;

  const SaveFromCamera({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          try {
            // iOS and Android need camera access
            if (!await Permission.camera.request().isGranted) {
              throw ('Camera Permission Required');
            }
            XFile? media = video
                ? await ImagePicker().pickVideo(source: ImageSource.camera)
                : await ImagePicker().pickImage(source: ImageSource.camera);
            if (media != null) {
              File originalFile = File(media.path);
              // Grant permission
              await _grantPermissions();
              // Save
              File file = await AddToGallery.addToGallery(
                originalFile: originalFile,
                albumName: _albumName,
                deleteOriginalFile: true,
                keepFilename: true,
              );
              await _saveGalleryPath(file.path);
              if (!context.mounted) return;
              await _showAlertMessage(context, file.path);
            }
          } on PlatformException catch (e) {
            if (!context.mounted) return;
            await _showError(context, 'Error: ${e.message}');
          } catch (e) {
            if (!context.mounted) return;
            await _showError(context, 'Error: ${e.toString()}');
          }
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: video
                ? <Widget>[Icon(Icons.videocam), Text('Record Video')]
                : <Widget>[Icon(Icons.camera_alt), Text('Take Photo')],
          ),
        ),
      ),
    );
  }
}

bool _isVideo(String path) =>
    ['.mp4', '.mov'].contains(extension(path).toLowerCase());

/// Images show a thumbnail, videos show an icon and their path
Widget _preview(String path, double height) {
  if (!_isVideo(path)) {
    return Image.file(File(path), height: height);
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Icon(Icons.videocam, size: height / 2),
      Text(path),
    ],
  );
}

Future<void> _showAlertMessage(BuildContext context, String path) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Saved to Gallery'),
        content: _preview(path, 200),
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

Future<void> _showError(BuildContext context, String message) async {
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

Future<void> _grantPermissions() async {
  final int? androidVersion = Platform.isAndroid
      ? (await DeviceInfoPlugin().androidInfo).version.sdkInt
      : null;
  // We need storage on:
  // - iOS to pick files from other apps
  // - Android < 13 for legacy access
  if (Platform.isIOS || (androidVersion != null && androidVersion <= 32)) {
    if (!await Permission.storage.request().isGranted) {
      throw ('Storage Permission Required');
    }
  }
  // We need photos on:
  // - iOS to pick files from this app
  // - Android >= 13
  if (Platform.isIOS || (androidVersion != null && androidVersion >= 33)) {
    if (!await Permission.photos.request().isGranted) {
      throw ('Photos Permission Required');
    }
  }
}

Future<File> _copyAssetLocally(String path) async {
  ByteData byteData = await rootBundle.load(path);
  File file = await _getBlankFileForAsset(path: path, prefix: 'assets');
  await file.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );
  return file;
}

Future<File> _getBlankFileForAsset({
  required String path,
  required String prefix,
}) async {
  String fileExt = extension(path);
  int now = DateTime.now().millisecondsSinceEpoch;
  String fileName = '$prefix-$now$fileExt';
  Directory directory = await getTemporaryDirectory();
  return File('${directory.path}/$fileName');
}

Future<void> _saveGalleryPath(String path) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('galleryPath', path);
}

Future<String?> _getGalleryPath() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? path = prefs.getString('galleryPath');
  // iOS paths change between app updates, so rebuild them from the documents
  // directory, see "An Important Note about iOS Filepaths" in the README
  if (path != null && Platform.isIOS) {
    Directory directory = await getApplicationDocumentsDirectory();
    path = '${directory.path}/${basename(path)}';
  }
  return path;
}
