# Add to Gallery

Adds images and videos to the Android Gallery and iOS Photos

<a href="https://youtu.be/TUq8rw1LuXc">
  <img src="https://flowmobile.imgix.net/users/NM99Dl5xszYqmKfU8X1Y17oEqg93/uploads/XFMKOvCYmwy64OCItDQ2/Flutter%20__%20Add%20To%20Gallery%20Package%202-22%20screenshot.png">
</a>

View example app

💡 There are a couple of important notes about **Google photos** and **iOS filepaths**. Jump to the end of this page for info!

## Installation

Add `add_to_gallery` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Permissions

You need the following permissions in your app:

- **iOS**
  - `NSPhotoLibraryUsageDescription`
  - This allows the plugin to use the [PHPhotoLibrary](https://developer.apple.com/documentation/photokit/phphotolibrary/) APIs to add assets to the user's photo library.
- **Android**
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE`
  - If you target Android 10, you will also need the [requestLegacyExternalStorage="true"](https://developer.android.com/training/data-storage/use-cases#opt-out-in-production-app) in your AndroidManifest.
  - NB: Android < 13 needs `storge` permission
  - NB: Android >= 13 needs `photos` permission
    - ^ the example app shows how to request these permissions

This plugin **does not** manage permissions for you. _By excluding permissions from our plugin we have created a simple, reliable plugin._

We recommend using [permission_handler](https://pub.dev/packages/permission_handler) to handle permissions.

## Usage

There's only one method. It copies the source file to the gallery and returns the new file.

```dart
File file = await AddToGallery.addToGallery(
  originalFile: File('/Some/Media/Path.jpg'),
  albumName: 'My Awesome App',
  deleteOriginalFile: false,
  keepFilename: true,
);
print("Savd to gallery with Path: ${file.path}");
```

Using [permission_handler](https://pub.dev/packages/permission_handler), this may look like:

```dart
Future<void> _addToGalleryExample() async {
  try {
    await _grantPermissions();
    File file = await AddToGallery.addToGallery(
      originalFile: File('/Some/Media/Path.jpg'),
      albumName: 'My Awesome App',
      deleteOriginalFile: true,
      keepFilename: true,
    );
    print("Savd to gallery with Path: ${file.path}");
  } catch(e) {
    print("Error: $e");
  }
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
```

## Example app

The [example app](/example) shows a few more edge-cases in action.

- Uses [permission_handler](https://pub.dev/packages/permission_handler) to request permissions
- Uses [image_picker](https://pub.dev/packages/image_picker) to take photos with the camera
- Copies assets to the gallery
- Uses [shared_preferences](https://pub.dev/packages/shared_preferences) to save and read the file path locally
  - _This shows that the assets are still accessible between reboots_

## Credits & Comparison

Add to Gallery is based on [gallery_saver](https://pub.dev/packages/gallery_saver) with some notable differences. Enough to warrant a new package rather than a pull-request. Generally speaking, I've simplified the API and unified the behaviour on iOS and Android. It also supports scoped storage on Android (which will be [enforced with Android 11](https://developer.android.com/about/versions/11/privacy/storage))

Big thanks to the [Tecocraft LTD team](https://www.tecocraft.co.uk/) for Android functionality on Android 10 and 11.

<table>
  <tr>
    <th>Feature</th>
    <th>
      <a href="https://pub.dev/packages/gallery_saver">gallery_saver</a>
      <br>
      <em>original package</em>
    </th>
    <th>
      <strong>add_to_gallery</strong>
      <br>
      <em>this package</em>
    </th>
  </tr>
  <tr>
    <td>General Behaviour</td>
    <td>
      Android
      <ul>
        <li>🔥 Source file is copied to the gallery</li>
        <li>🔥 The copy is not a tmp file</li>
        <li>👎 The file path is not returned</li>
        <li>👎 No way to find the new file path</li>
      </ul>
      iOS
      <ul>
        <li>🔥 Source file is linked to the gallery</li>
        <li>👎 If the source file is in a tmp directory it may be garbage collected</li>
        <li>👎 The file path is not returned</li>
        <li>🔥 The original file path is correct</li>
      </ul>
    </td>
    <td>
      Android and iOS
      <ul>
        <li>🔥 Source file is copied to the <a href="https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationDocumentsDirectory.html">getApplicationDocumentsDirectory</a> for persistence</li>
        <li>🔥 Your app has permission to access the file</li>
        <li>🔥 The new file path is returned</li>
        <li>Automatically deletes sourceFile - <em>defaults to false</em></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Return Value</td>
    <td>Returns <code>bool</code> for the success of the operation</ul>
    </td>
    <td>Returns a <code>File</code> pointing to the new file in the gallery</td>
  </tr>
  <tr>
    <td>Remote Files</td>
    <td>Automatically downloads files that start with <strong>http</strong></td>
    <td>Does not download files that start with <strong>http</strong></td>
  </tr>
  <tr>
    <td>Album Name</td>
    <td>Optional with default values</td>
    <td>Is required</td>
  </tr>
  <tr>
    <td>Image Manipulation</td>
    <td>
      Android
      <ul>
        <li>Rotates images according to EXIF data</li>
        <li>Creates Thumbnails</li>
      </ul>
      iOS
      <ul>
        <li>Does not manipulate images</li>
      </ul>
    </td>
    <td>Does not manipulate images</td>
  </tr>
  <tr>
    <td>Permissions</td>
    <td>Handled within the plugin. The first-call fails silently due to permissions race-condition</td>
    <td>Not handled within the plugin</td>
  </tr>
</table>

## 💡 An Important Note about Google photos

Google Photos has a built-in feature to remove exact duplicates. It can be confusing to see your media disappearing like this. I considered addressing this behaviour in the plugin, but decided against it. I expect plugin users to be creating unique images with the camera or other methods.

## 💡 An Important Note about iOS Filepaths

Simply, it will change when new versions of your app are released. For example:

- The user installs `1.0.0` of your app, the path is:
  `.../<A-UNIQUE-DIRECTORY>/Documents/your-file.jpg`
- The user upgrades to `2.0.0`, the path is now:
  `.../<A-DIFFERENT-UNIQUE-DIRECTORY>/Documents/your-file.jpg`

This becomes an issue when you try to access the file later, as the path has changed.

To handle this, you can use the `path_provider` package to build the path dynamically. Here's an example:

```dart
// 1. We used `add_to_gallery` to save a file, and stored the `file.path` locally (in a db, shared preferences etc.)
// 2. The user then updated their app
// 3. They re-opened the app, and we want to access the file again:
import 'package:path_provider/path_provider.dart';
final fileName = basename(filePath);
storageDirectory = await getApplicationDocumentsDirectory();
final sourcePath = '${storageDirectory.path}/$fileName'; // This is the new path
```
