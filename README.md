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

## Important Note about Google photos

Google Photos has a built-in feature to remove exact duplicates. This can be confusing behaviour. I considered addressing this behaviour in the plugin, but decided against it. But it's worth pointing out anyhow!

## Credits

Add to Gallery is based on [gallery_saver](https://pub.dev/packages/gallery_saver) with some notable differences. Enough to warrant a new package rather than a pull-request.

<table>
  <tr>
    <th>Feature</th>
    <th>
      add_to_gallery
      <br>
      <em>this package</em>
    </th>
    <th>
      <a href="https://pub.dev/packages/gallery_saver">gallery_saver</a>
      <br>
      <em>original package</em>
    </th>
  </tr>
  <tr>
    <td>Return Formats</td>
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
    <td>Temporary Files</td>
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
    <td>Remote Files (over http)</td>
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
    <td>Album Name</td>
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
    <td>Image Manipulation</td>
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
