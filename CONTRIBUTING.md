# Setting up

We've configured `fvm` to manage the Flutter SDK. You'll need to install it:

https://fvm.app/documentation/getting-started

If you're using `vscode`, the project `settings.json` points at the `fvm` version of Flutter.

# Release process

- Be sure to run `dart format .` to ensure all files are formatted correctly.
- Contact me to release: `david@oodavid.com` (or raise an issue)

Note to self, these are the commands to run:

- Test publishing:
  `fvm dart pub publish --dry-run`
- Release with:
  `fvm dart pub publish`
