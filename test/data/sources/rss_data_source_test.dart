import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:dio/dio.dart';

void main() {
  test('should parse RSS XML correctly', () {
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
    final dataSource = RssDataSource(dio: Dio());
    final items = dataSource.parseRss(xml, "Test Source");
    expect(items.first.title, "Test News");
  });
}
