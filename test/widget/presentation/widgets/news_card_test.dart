import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/presentation/widgets/news_card.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fa_IR', null);
  });

  final testItem = NewsItem(
    id: 1,
    remoteId: 'https://example.com/news/1',
    title: 'Test Title',
    content: 'Test Content',
    summary: 'Test Summary',
    sourceName: 'Test Source',
    publishDate: DateTime.now(),
  );

  testWidgets('NewsCard displays title and summary', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NewsCard(
            item: testItem,
            onTap: () {},
            onBookmarkToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Summary'), findsOneWidget);
  });

  testWidgets('NewsCard has lower opacity when read', (WidgetTester tester) async {
    final readItem = NewsItem(
      id: 2,
      remoteId: 'https://example.com/news/2',
      title: 'Read Title',
      content: 'Read Content',
      summary: 'Read Summary',
      sourceName: 'Read Source',
      publishDate: DateTime.now(),
      isRead: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NewsCard(
            item: readItem,
            onTap: () {},
            onBookmarkToggle: () {},
          ),
        ),
      ),
    );

    final opacityWidget = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(NewsCard),
        matching: find.byType(Opacity),
      ).first,
    );

    expect(opacityWidget.opacity, 0.5);
  });

  testWidgets('NewsCard displays bookmark icon correctly', (WidgetTester tester) async {
    final bookmarkedItem = NewsItem(
      id: 3,
      remoteId: 'https://example.com/news/3',
      title: 'Bookmarked Title',
      content: 'Bookmarked Content',
      summary: 'Bookmarked Summary',
      sourceName: 'Bookmarked Source',
      publishDate: DateTime.now(),
      isBookmarked: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NewsCard(
            item: bookmarkedItem,
            onTap: () {},
            onBookmarkToggle: () {},
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.bookmark);
  });
}
