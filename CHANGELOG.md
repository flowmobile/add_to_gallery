## 1.0.0

**Breaking:** requires Flutter 3.44 / Dart 3.12, iOS 13 and Android API 24. Apps on older versions of Flutter can stay on 0.5.0+1.

- Adds Swift Package Manager support on iOS, alongside CocoaPods
- Saves videos on Android and iOS (#2)
  - Android uses the right MediaStore collection and MIME type, fixing `Unsupported MIME type images/*` on Android 14 (#16). Thanks @DevTello for the original fix
  - Android saves videos to `Movies/<albumName>`; images stay in `Pictures/<albumName>`
- Migrates Android to built-in Kotlin with AGP 9 and Java 17 (#14, #15)
- Bundles the iOS privacy manifest, which wasn't included before
- iOS sends results on the main thread and returns an error instead of crashing on bad arguments
- Android errors now have a code and message (`could_not_save_file`, `file_not_found`, `bad_args`) instead of a bare `error`
- `deleteOriginalFile` is honoured even when the platform doesn't return a path
- Reports an error, instead of success, when the gallery doesn't create the asset
- Android saves on a background thread, so large videos don't block the UI
- iOS accepts limited Photos access, which can still create albums and add new assets
- Documents which Android versions need which permissions: Android 10 and above don't need a permission to save

## 0.5.0+1

- Updated README.md to:
  - Show the `keepFilename` parameter
  - Cover an important note about iOS file paths

## 0.5.0

- Added Android namespace to avoid conflicts with other packages

## 0.4.0+1

- Ran `dart format .` as advised by the Pub Points page

## 0.4.0

- Update iOS & Android build system files
- Adds option to keep the original filename, thank you @Correct-Syntax
- Documentation for permissions on different Android versions

## 0.3.0

- Update kotlin version to 1.5.31

## 0.2.0+2

- Documentation for Android 10 permissions

## 0.2.0

- No longer handles permissions internally (use [permission_handler](https://pub.dev/packages/permission_handler) instead)
- Returns `File` instead of `String`
- Support for scoped storage on android
  - No longer need to use `requestLegacyExternalStorage="true"` in `AndroidManifest.xml`

## 0.1.1

- Refactoring internal logic

## 0.1.0

- Initial release
