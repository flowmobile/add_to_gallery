import 'dart:io';

import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:add_to_gallery/src/get_file_type.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  FakePathProviderPlatform(this.documentsPath);

  final String documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('add_to_gallery');

  group('getFileType', () {
    test('detects images', () {
      expect(getFileType('/a/photo.jpg'), 'image');
      expect(getFileType('/a/photo.HEIC'), 'image');
    });

    test('detects videos', () {
      expect(getFileType('/a/clip.mp4'), 'video');
      expect(getFileType('/a/clip.MOV'), 'video');
    });

    test('throws for other files', () {
      expect(() => getFileType('/a/document.pdf'), throwsArgumentError);
    });
  });

  group('addToGallery', () {
    late Directory tempDir;
    late Directory documentsDir;
    late List<MethodCall> calls;
    // What the mocked platform returns, given the path it was sent
    late String? Function(String path) platformResult;

    File createSourceFile(String name) {
      final File file = File(p.join(tempDir.path, 'source', name));
      file.createSync(recursive: true);
      file.writeAsBytesSync([1, 2, 3]);
      return file;
    }

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('add_to_gallery_test');
      documentsDir = Directory(p.join(tempDir.path, 'documents'))..createSync();
      PathProviderPlatform.instance = FakePathProviderPlatform(
        documentsDir.path,
      );
      calls = <MethodCall>[];
      platformResult = (String path) => path;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            calls.add(methodCall);
            return platformResult(methodCall.arguments['path'] as String);
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      tempDir.deleteSync(recursive: true);
    });

    test('sends a copy of an image to the platform', () async {
      final File original = createSourceFile('photo.jpg');

      final File result = await AddToGallery.addToGallery(
        originalFile: original,
        albumName: 'My Album',
        deleteOriginalFile: false,
        keepFilename: true,
      );

      final String copiedPath = p.join(documentsDir.path, 'photo.jpg');
      expect(calls, hasLength(1));
      expect(calls.single.method, 'addToGallery');
      expect(calls.single.arguments, <String, dynamic>{
        'type': 'image',
        'path': copiedPath,
        'album': 'My Album',
      });
      expect(result.path, copiedPath);
      expect(result.existsSync(), isTrue);
      expect(original.existsSync(), isTrue);
    });

    test('sends videos with the video type', () async {
      await AddToGallery.addToGallery(
        originalFile: createSourceFile('clip.mp4'),
        albumName: 'My Album',
        deleteOriginalFile: false,
        keepFilename: true,
      );

      expect(calls.single.arguments['type'], 'video');
    });

    test('generates a unique filename when keepFilename is false', () async {
      final File result = await AddToGallery.addToGallery(
        originalFile: createSourceFile('photo.jpg'),
        albumName: 'My Album',
        deleteOriginalFile: false,
        keepFilename: false,
      );

      expect(p.dirname(result.path), documentsDir.path);
      expect(
        p.basename(result.path),
        matches(RegExp(r'^image-[0-9a-f-]{36}\.jpg$')),
      );
    });

    test('returns the gallery file and removes the copy when the platform '
        'creates a new file', () async {
      final String galleryPath = p.join(tempDir.path, 'gallery', 'photo.jpg');
      platformResult = (_) => galleryPath;
      final File original = createSourceFile('photo.jpg');

      final File result = await AddToGallery.addToGallery(
        originalFile: original,
        albumName: 'My Album',
        deleteOriginalFile: true,
        keepFilename: true,
      );

      expect(result.path, galleryPath);
      expect(
        File(p.join(documentsDir.path, 'photo.jpg')).existsSync(),
        isFalse,
      );
      expect(original.existsSync(), isFalse);
    });

    test('keeps the copy and deletes the original when the platform returns '
        'nothing', () async {
      platformResult = (_) => null;
      final File original = createSourceFile('photo.jpg');

      final File result = await AddToGallery.addToGallery(
        originalFile: original,
        albumName: 'My Album',
        deleteOriginalFile: true,
        keepFilename: true,
      );

      expect(result.path, p.join(documentsDir.path, 'photo.jpg'));
      expect(result.existsSync(), isTrue);
      expect(original.existsSync(), isFalse);
    });

    test('rejects unsupported files before calling the platform', () async {
      await expectLater(
        AddToGallery.addToGallery(
          originalFile: createSourceFile('document.pdf'),
          albumName: 'My Album',
          deleteOriginalFile: false,
          keepFilename: true,
        ),
        throwsArgumentError,
      );
      expect(calls, isEmpty);
    });
  });
}
