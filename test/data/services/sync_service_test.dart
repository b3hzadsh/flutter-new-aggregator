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
    
    // Register fallback for DateTime
    registerFallbackValue(DateTime.now());
  });

  test('sync should cleanup old news, fetch items and store new ones with feed source association', () async {
    final feed = FeedSource(id: 1, name: 'Test', url: 'url', isLocalOnly: false, language: 'fa');
    
    when(() => mockStorage.deleteOldNews(any())).thenAnswer((_) async {});
    when(() => mockStorage.getAllFeedSources()).thenAnswer((_) async => [feed]);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({});
    when(() => mockStorage.insertMany(any())).thenAnswer((_) async {});

    final newItem = NewsItem(
      remoteId: 'id1',
      title: 'Title 1',
      content: 'Content 1',
      summary: 'Summary 1',
      sourceName: 'test',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url', 'Test'))
        .thenAnswer((_) async => [newItem]);

    await syncService.sync(true);

    verify(() => mockStorage.deleteOldNews(any())).called(1);
    final captured = verify(() => mockStorage.insertMany(captureAny())).captured;
    final insertedItems = captured.first as List<NewsItem>;
    expect(insertedItems.length, 1);
    expect(insertedItems.first.remoteId, 'id1');
    expect(insertedItems.first.feedSource.target, feed);
  });

  test('sync should avoid duplicates based on remoteId', () async {
    final feed = FeedSource(id: 1, name: 'Test', url: 'url', isLocalOnly: false, language: 'fa');
    
    when(() => mockStorage.deleteOldNews(any())).thenAnswer((_) async {});
    when(() => mockStorage.getAllFeedSources()).thenAnswer((_) async => [feed]);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({'id1'});

    final newItem = NewsItem(
      remoteId: 'id1', // Same remoteId
      title: 'New Title',
      content: 'New Content',
      summary: 'New Summary',
      sourceName: 'test',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url', 'Test'))
        .thenAnswer((_) async => [newItem]);

    await syncService.sync(true);

    verifyNever(() => mockStorage.insertMany(any()));
  });

  test('sync should filter isLocalOnly feeds if not Iranian IP', () async {
    final feedLocal = FeedSource(id: 1, name: 'Local', url: 'url_local', isLocalOnly: true, language: 'fa');
    final feedGlobal = FeedSource(id: 2, name: 'Global', url: 'url_global', isLocalOnly: false, language: 'en');
    
    when(() => mockStorage.deleteOldNews(any())).thenAnswer((_) async {});
    when(() => mockStorage.getAllFeedSources()).thenAnswer((_) async => [feedLocal, feedGlobal]);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({});
    when(() => mockStorage.insertMany(any())).thenAnswer((_) async {});

    final itemGlobal = NewsItem(
      remoteId: 'id_global',
      title: 'Global Title',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'src',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url_global', 'Global'))
        .thenAnswer((_) async => [itemGlobal]);

    await syncService.sync(false);

    final captured = verify(() => mockStorage.insertMany(captureAny())).captured;
    final insertedItems = captured.first as List<NewsItem>;
    expect(insertedItems.length, 1);
    expect(insertedItems.first.title, 'Global Title');
    
    verify(() => mockDataSource.fetchFeed('url_global', 'Global')).called(1);
    verifyNever(() => mockDataSource.fetchFeed('url_local', any()));
  });

  test('sync should NOT filter isLocalOnly feeds if Iranian IP', () async {
    final feedLocal = FeedSource(id: 1, name: 'Local', url: 'url_local', isLocalOnly: true, language: 'fa');
    
    when(() => mockStorage.deleteOldNews(any())).thenAnswer((_) async {});
    when(() => mockStorage.getAllFeedSources()).thenAnswer((_) async => [feedLocal]);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({});
    when(() => mockStorage.insertMany(any())).thenAnswer((_) async {});

    final itemLocal = NewsItem(
      remoteId: 'id_local',
      title: 'Local Title',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'src',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url_local', 'Local'))
        .thenAnswer((_) async => [itemLocal]);

    await syncService.sync(true);

    verify(() => mockDataSource.fetchFeed('url_local', 'Local')).called(1);
    verify(() => mockStorage.insertMany(any())).called(1);
  });
}
