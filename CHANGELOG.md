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
