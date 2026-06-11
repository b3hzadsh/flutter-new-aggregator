# RSS Data Source Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve robustness and testing of `RssDataSource` by adding error handling, better parsing, and comprehensive tests.

**Architecture:** Update `RssDataSource` to handle edge cases in RSS parsing and use `mocktail` for dependency injection in tests.

**Tech Stack:** Dart, Flutter, Dio, XML, Mocktail, Intl

---

### Task 1: Setup Mocktail

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add mocktail to dev_dependencies**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  objectbox_generator: ^2.5.1
  build_runner: ^2.4.8
  flutter_lints: ^6.0.0
  mocktail: ^1.0.4
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: Success

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "test: add mocktail to dev_dependencies"
```

### Task 2: Mock Dio and Basic Field Assertions (TDD)

**Files:**
- Modify: `test/data/sources/rss_data_source_test.dart`

- [ ] **Step 1: Update test to use mocktail and mock Dio**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late MockDio mockDio;
  late RssDataSource dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = RssDataSource(dio: mockDio);
  });

  test('should parse RSS XML correctly with all fields', () async {
    const xml = '''
    <rss version="2.0">
      <channel>
        <item>
          <title>Test News</title>
          <description>Test Summary</description>
          <link>https://test.com/1</link>
          <pubDate>Mon, 11 Jun 2026 12:00:00 +0330</pubDate>
        </item>
      </channel>
    </rss>''';

    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
      data: xml,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final items = await dataSource.fetchFeed("https://test.com/rss", "Test Source");
    
    expect(items.length, 1);
    expect(items.first.title, "Test News");
    expect(items.first.content, "Test Summary");
    expect(items.first.remoteId, "https://test.com/1");
    expect(items.first.sourceName, "Test Source");
    // publishDate check will be added in Task 4
  });
}
```

- [ ] **Step 2: Run test to verify it passes (with current implementation)**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add test/data/sources/rss_data_source_test.dart
git commit -m "test: use mocktail to mock Dio in RssDataSource tests"
```

### Task 3: Robust Parsing & Missing Tags (TDD)

**Files:**
- Modify: `test/data/sources/rss_data_source_test.dart`
- Modify: `lib/data/sources/rss_data_source.dart`

- [ ] **Step 1: Write test for missing tags**

```dart
  test('should handle missing tags gracefully', () async {
    const xml = '''
    <rss version="2.0">
      <channel>
        <item>
        </item>
      </channel>
    </rss>''';

    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
      data: xml,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final items = await dataSource.fetchFeed("https://test.com/rss", "Test Source");
    
    expect(items.length, 1);
    expect(items.first.title, "");
    expect(items.first.content, "");
    expect(items.first.remoteId, "");
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: FAIL (StateError: No element)

- [ ] **Step 3: Implement robust parsing using firstOrNull**

```dart
  List<NewsItem> parseRss(String xmlString, String sourceName) {
    final document = XmlDocument.parse(xmlString);
    final items = document.findAllElements('item');
    return items.map((node) {
      final title = node.findElements('title').firstOrNull?.innerText ?? '';
      final description = node.findElements('description').firstOrNull?.innerText ?? '';
      final link = node.findElements('link').firstOrNull?.innerText ?? '';
      // ...
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/sources/rss_data_source.dart test/data/sources/rss_data_source_test.dart
git commit -m "feat: make RSS parsing robust against missing tags"
```

### Task 4: pubDate Parsing (TDD)

**Files:**
- Modify: `test/data/sources/rss_data_source_test.dart`
- Modify: `lib/data/sources/rss_data_source.dart`

- [ ] **Step 1: Update test to assert publishDate**

```dart
    final items = await dataSource.fetchFeed("https://test.com/rss", "Test Source");
    
    expect(items.length, 1);
    expect(items.first.title, "Test News");
    expect(items.first.publishDate.year, 2026);
    expect(items.first.publishDate.month, 6);
    expect(items.first.publishDate.day, 11);
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: FAIL (Wrong date)

- [ ] **Step 3: Implement pubDate parsing**

```dart
import 'package:intl/intl.dart';

// Inside parseRss:
      final pubDateStr = node.findElements('pubDate').firstOrNull?.innerText ?? '';
      DateTime publishDate;
      try {
        // RSS 2.0 pubDate is typically RFC 822 format
        // Example: Mon, 11 Jun 2026 12:00:00 +0330
        // We'll try to parse it using common formats
        publishDate = _parseRssDate(pubDateStr);
      } catch (e) {
        publishDate = DateTime.now();
      }

// Helper method:
  DateTime _parseRssDate(String dateString) {
    try {
      // RFC 822 format
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(dateString);
    } catch (e) {
      return DateTime.tryParse(dateString) ?? DateTime.now();
    }
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/sources/rss_data_source.dart test/data/sources/rss_data_source_test.dart
git commit -m "feat: parse pubDate from RSS feed"
```

### Task 5: Error Handling (TDD)

**Files:**
- Modify: `test/data/sources/rss_data_source_test.dart`
- Modify: `lib/data/sources/rss_data_source.dart`

- [ ] **Step 1: Write test for Dio error and Invalid XML**

```dart
  test('should return empty list on Dio error', () async {
    when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
    
    final items = await dataSource.fetchFeed("https://test.com/rss", "Test Source");
    expect(items, isEmpty);
  });

  test('should return empty list on invalid XML', () async {
    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
      data: "not xml",
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));
    
    final items = await dataSource.fetchFeed("https://test.com/rss", "Test Source");
    expect(items, isEmpty);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: FAIL (Throws exception)

- [ ] **Step 3: Implement try-catch blocks**

```dart
  Future<List<NewsItem>> fetchFeed(String url, String sourceName) async {
    try {
      final response = await dio.get(url);
      return parseRss(response.data.toString(), sourceName);
    } catch (e) {
      return [];
    }
  }

  List<NewsItem> parseRss(String xmlString, String sourceName) {
    try {
      final document = XmlDocument.parse(xmlString);
      // ... existing logic ...
    } catch (e) {
      return [];
    }
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/sources/rss_data_source.dart test/data/sources/rss_data_source_test.dart
git commit -m "feat: add error handling for network and parsing errors"
```

### Task 6: HTML Cleaning (TDD)

**Files:**
- Modify: `test/data/sources/rss_data_source_test.dart`
- Modify: `lib/data/sources/rss_data_source.dart`

- [ ] **Step 1: Write test with HTML in description**

```dart
  test('should clean HTML tags from summary', () async {
    const xml = '''
    <rss version="2.0">
      <channel>
        <item>
          <description>&lt;p&gt;Hello &lt;b&gt;World&lt;/b&gt;&lt;/p&gt;</description>
        </item>
      </channel>
    </rss>''';

    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
      data: xml,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final items = await dataSource.fetchFeed("https://test.com/rss", "Test Source");
    expect(items.first.summary, "Hello World");
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: FAIL (Contains tags or encoded tags)

- [ ] **Step 3: Implement HTML cleaning**

```dart
  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // Use it in parseRss for summary
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/sources/rss_data_source_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/sources/rss_data_source.dart test/data/sources/rss_data_source_test.dart
git commit -m "feat: clean HTML tags from news summary"
```

### Task 7: Verification

- [ ] **Step 1: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found
