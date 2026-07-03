// Smoke test: the app builds, renders the brand splash, and navigates on.

import 'package:flutter_test/flutter_test.dart';

import 'package:sportyqo/main.dart';

void main() {
  testWidgets('App builds, splash renders, and navigation timer fires',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SportyQoApp());
    // First frame renders without throwing.
    expect(tester.takeException(), isNull);

    // Let the 2.2s splash timer fire and the 600ms fade transition finish,
    // otherwise the test fails with a pending Timer.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });
}
