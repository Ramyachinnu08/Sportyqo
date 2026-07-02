// Basic smoke test: the app builds and shows the splash screen.

import 'package:flutter_test/flutter_test.dart';

import 'package:sportyqo/main.dart';

void main() {
  testWidgets('App builds and renders the splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SportyQoApp());
    // First frame renders without throwing.
    expect(tester.takeException(), isNull);
  });
}
