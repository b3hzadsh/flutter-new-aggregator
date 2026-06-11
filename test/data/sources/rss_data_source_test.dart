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
}
