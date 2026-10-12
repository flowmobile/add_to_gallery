import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:add_to_gallery_example/main.dart';

void main() {
  testWidgets('Verify UI is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data!.startsWith('Take Photo'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data!.startsWith('Save Local Asset'),
      ),
      findsNWidgets(2),
    );
  });
}
