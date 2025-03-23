// File: test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:betachin/main.dart'; // Kept this import as it's used

void main() {
  testWidgets('HomeScreen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BetaChinApp());

    // Verify that the HomeScreen title is present
    expect(find.text('BetaChin Real Estate'), findsOneWidget);

    // Suggestion: Added a test to verify the "Featured Listings" section
    expect(find.text('Featured Listings'), findsOneWidget);
  });
}
