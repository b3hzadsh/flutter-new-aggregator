import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_aggregator/domain/repositories/rss_fetcher.dart';
import 'package:news_aggregator/domain/repositories/rss_parser.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';

class MockRssFetcher extends Mock implements RssFetcher {}
class MockRssParser extends Mock implements RssParser {}
class MockNewsStorage extends Mock implements NewsStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Fallback values for complex mocktail types
void registerFallbackValues() {
  registerFallbackValue(NewsItem(
    remoteId: 'fallback',
    title: 'fallback',
    content: 'fallback',
    summary: 'fallback',
    sourceName: 'fallback',
    publishDate: DateTime.now(),
  ));
}
