import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late RssDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = RssDataSource(dio: mockDio);
  });

  group('RssDataSource', () {
    const testXml = '''
    <rss version="2.0">
      <channel>
        <item>
          <title>Test Title</title>
          <description>&lt;p&gt;Test Content with HTML&lt;/p&gt;</description>
          <link>https://test.com/1</link>
          <pubDate>Mon, 11 Jun 2026 12:00:00 +0330</pubDate>
        </item>
      </channel>
    </rss>''';

    test('should parse RSS XML correctly with HTML stripping and date parsing', () {
      final items = dataSource.parseRss(testXml, "Test Source");

      expect(items.length, 1);
      expect(items.first.title, "Test Title");
      expect(items.first.content, "Test Content with HTML");
      expect(items.first.summary, "Test Content with HTML");
      expect(items.first.remoteId, "https://test.com/1");
      expect(items.first.sourceName, "Test Source");
      // Date parsing might depend on locale/timezone, but it should not be null
      expect(items.first.publishDate, isA<DateTime>());
    });

    test('should handle missing tags gracefully', () {
      const brokenXml = '''
      <rss version="2.0">
        <channel>
          <item>
            <title>Only Title</title>
          </item>
        </channel>
      </rss>''';

      final items = dataSource.parseRss(brokenXml, "Test Source");
      expect(items.length, 1);
      expect(items.first.title, "Only Title");
      expect(items.first.content, "");
    });

    test('should return empty list on malformed XML', () {
      final items = dataSource.parseRss("not xml", "Test Source");
      expect(items, isEmpty);
    });

    test('fetchFeed returns parsed items on success', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: testXml,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final items = await dataSource.fetchFeed('https://test.com/rss', 'Test');
      expect(items.length, 1);
      expect(items.first.title, "Test Title");
    });

    test('fetchFeed returns empty list on network error', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final items = await dataSource.fetchFeed('https://test.com/rss', 'Test');
      expect(items, isEmpty);
    });
  });
}
