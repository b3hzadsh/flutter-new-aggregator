import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_aggregator/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App fetches and displays news list successfully', (WidgetTester tester) async {
    // Launch the application
    app.main();
    await tester.pumpAndSettle(); // Wait for initial animations

    // Initial state: Might be loading or showing cached data
    // Trigger a manual pull-to-refresh to force a network fetch
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      await tester.drag(listView, const Offset(0, 300));
      await tester.pumpAndSettle();
    }

    // Wait for network response (timeout after 10 seconds)
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Assert: Verify at least one NewsCard or ListTile is rendered
    expect(find.byType(Card), findsWidgets, reason: 'Expected news cards to be rendered after fetch.');
    
    // Assert: Ensure no error text is visible on the screen
    expect(find.textContaining('Error'), findsNothing);
  });
}
