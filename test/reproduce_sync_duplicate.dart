import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/domain/entities/feed_source.dart';

class MockRssDataSource extends Mock implements RssDataSource {}
class MockNewsStorage extends Mock implements NewsStorage {}

void main() {
  late MockNewsStorage mockStorage;
  late MockRssDataSource mockDataSource;
  late SyncService syncService;

  setUp(() {
    mockStorage = MockNewsStorage();
    mockDataSource = MockRssDataSource();
    syncService = SyncService(mockDataSource, mockStorage);
    registerFallbackValue(DateTime.now());
  });

  test('sync SHOULD avoid duplicates from different feeds in the same sync session', () async {
    final feed1 = FeedSource(id: 1, name: 'Feed 1', url: 'url1', isLocalOnly: false, language: 'fa');
    final feed2 = FeedSource(id: 2, name: 'Feed 2', url: 'url2', isLocalOnly: false, language: 'fa');
    
    when(() => mockStorage.deleteOldNews(any())).thenAnswer((_) async {});
    when(() => mockStorage.getAllFeedSources()).thenAnswer((_) async => [feed1, feed2]);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({});
    when(() => mockStorage.insertMany(any())).thenAnswer((_) async {});

    final item1 = NewsItem(
      remoteId: 'duplicate_id',
      title: 'Title 1',
      content: 'Content 1',
      summary: 'Summary 1',
      sourceName: 'src1',
      publishDate: DateTime.now(),
    );

    final item2 = NewsItem(
      remoteId: 'duplicate_id', // Same remoteId!
      title: 'Title 2',
      content: 'Content 2',
      summary: 'Summary 2',
      sourceName: 'src2',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url1', 'Feed 1')).thenAnswer((_) async => [item1]);
    when(() => mockDataSource.fetchFeed('url2', 'Feed 2')).thenAnswer((_) async => [item2]);

    await syncService.sync(true);

    final captured = verify(() => mockStorage.insertMany(captureAny())).captured;
    final insertedItems = captured.first as List<NewsItem>;
    
    // This is expected to fail if the bug exists
    expect(insertedItems.length, 1, reason: 'Should only insert the item once even if found in multiple feeds');
  });
}
