# Add to Gallery

Adds images and videos to the Android Gallery and iOS Photos

<a href="https://youtu.be/TUq8rw1LuXc">
  <img src="https://flowmobile.imgix.net/users/NM99Dl5xszYqmKfU8X1Y17oEqg93/uploads/XFMKOvCYmwy64OCItDQ2/Flutter%20__%20Add%20To%20Gallery%20Package%202-22%20screenshot.png">
</a>

View example app

## Installation

Add `add_to_gallery` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS

Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called _Privacy - Photo Library Usage Description_ in the visual editor.

### Android

* `android.permission.WRITE_EXTERNAL_STORAGE` - Permission for usage of external storage

## Usage

There's only one method. It copies the source file to the gallery and returns the new path.

```dart
String path = await AddToGallery.addToGallery(
  originalFile: File('/Some/Media/Path.jpg'),
  albumName: 'My Awesome App',
  deleteOriginalFile: false,
);
print(path);
```

### An Important Note about Google photos

Google Photos has a built-in feature to remove exact duplicates. It can be confusing to see your media disappearing like this. I considered addressing this behaviour in the plugin, but decided against it. I expect plugin users to be creating unique images with the camera or other methods.

## Credits & Comparison

Add to Gallery is based on [gallery_saver](https://pub.dev/packages/gallery_saver) with some notable differences. Enough to warrant a new package rather than a pull-request. Generally speaking, I've simplified the package somewhat and unified the behaviour on iOS and Android.

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
        <li>👎 No way to find the file path</li>
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
        <li>Automatically delete sourceFile - <em>defaults to false</em></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Return Value</td>
    <td>Returns <code>bool</code> for the success of the operation</ul>
    </td>
    <td>Returns the <code>path</code> of the file in the gallery</td>
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
</table>
