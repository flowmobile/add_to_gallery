import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_to_gallery/save_to_gallery.dart';

void main() {
  const MethodChannel channel = MethodChannel('save_to_gallery');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
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
    channel.setMockMethodCallHandler(null);
  });

  test('save image', () async {
    expect(await SaveToGallery.saveImage('/storage/emulated/image.jpg'), true);
  });

  test('save video', () async {
    expect(await SaveToGallery.saveVideo('/storage/emulated/video.mov'), false);
  });
}
