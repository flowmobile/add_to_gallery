import 'package:path/path.dart';

const List<String> _videoFormats = [
  '.mp4',
  '.mov',
  '.avi',
  '.wmv',
  '.3gp',
  '.mkv',
  '.flv'
];

const List<String> _imageFormats = [
  '.jpeg',
  '.png',
  '.jpg',
  '.gif',
  '.webp',
  '.tif',
  '.heic'
];

/// Returns 'video' or 'image' based on the file extension
///
/// Throws an error if the filePath is neither
String getFileType(String filePath) {
  if (_videoFormats.contains(extension(filePath).toLowerCase())) {
    return 'video';
  }
  if (_imageFormats.contains(extension(filePath).toLowerCase())) {
    return 'image';
  }
  throw ArgumentError('Path does not have an image file extension');
}
