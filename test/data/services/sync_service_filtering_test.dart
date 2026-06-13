import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/domain/entities/feed_source.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsStorage extends Mock implements NewsStorage {}
class MockRssDataSource extends Mock implements RssDataSource {}

void main() {
  late MockNewsStorage mockStorage;
  late MockRssDataSource mockDataSource;
  late SyncService syncService;

  setUp(() {
    mockStorage = MockNewsStorage();
    mockDataSource = MockRssDataSource();
    syncService = SyncService(mockDataSource, mockStorage);
  });

  test('Sync should filter out local feeds for non-Iranian IP', () async {
    final iranianFeed = FeedSource(name: 'Fars', url: 'fars.com', language: 'fa', isLocalOnly: true);
    final globalFeed = FeedSource(name: 'Reuters', url: 'reuters.com', language: 'en', isLocalOnly: false);
    
    when(() => mockStorage.getAllFeedSources()).thenAnswer((_) async => [iranianFeed, globalFeed]);
    when(() => mockDataSource.fetchFeed(any(), any())).thenAnswer((_) async => []);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({});
    when(() => mockStorage.insertMany(any())).thenAnswer((_) async {});
    when(() => mockStorage.deleteOldNews(any())).thenAnswer((_) async {});

    // Sync for Global IP (non-Iranian)
    await syncService.sync(false);

    // Verify only global feed is fetched
    verify(() => mockDataSource.fetchFeed('reuters.com', 'Reuters')).called(1);
    verifyNever(() => mockDataSource.fetchFeed('fars.com', 'Fars'));
  });
}
