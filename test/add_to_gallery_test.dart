import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:add_to_gallery/add_to_gallery.dart';

void main() {
  const MethodChannel channel = MethodChannel('add_to_gallery');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'saveImage':
          return true;
        case 'saveVideo':
          return false;
      }
      return 'unknown method';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('save image', () async {
    File originalFile = File('/storage/emulated/image.jpg');
    expect(
      await AddToGallery.addToGallery(
        originalFile: originalFile,
        albumName: 'Add to Gallery',
        deleteOriginalFile: true,
      ),
      true,
    );
  });

  test('save video', () async {
    File originalFile = File('/storage/emulated/video.mov');
    expect(
      await AddToGallery.addToGallery(
        originalFile: originalFile,
        albumName: 'Add to Gallery',
        deleteOriginalFile: true,
      ),
      false,
    );
  });
}
