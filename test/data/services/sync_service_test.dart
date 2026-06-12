import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/domain/entities/category.dart';

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
  });

  test('sync should fetch items and store new ones with category association', () async {
    final category = Category(id: 1, name: 'Test', remoteUrl: 'url', source: 'test');
    
    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => [category]);
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

    when(() => mockDataSource.fetchFeed('url', 'test'))
        .thenAnswer((_) async => [newItem]);

    await syncService.sync(true);

    final captured = verify(() => mockStorage.insertMany(captureAny())).captured;
    final insertedItems = captured.first as List<NewsItem>;
    expect(insertedItems.length, 1);
    expect(insertedItems.first.remoteId, 'id1');
    expect(insertedItems.first.category.target, category);
  });

  test('sync should avoid duplicates based on remoteId', () async {
    final category = Category(id: 1, name: 'Test', remoteUrl: 'url', source: 'test');
    
    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => [category]);
    when(() => mockStorage.getAllRemoteIds()).thenReturn({'id1'});

    final newItem = NewsItem(
      remoteId: 'id1', // Same remoteId
      title: 'New Title',
      content: 'New Content',
      summary: 'New Summary',
      sourceName: 'test',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url', 'test'))
        .thenAnswer((_) async => [newItem]);

    await syncService.sync(true);

    verifyNever(() => mockStorage.insertMany(any()));
  });

  test('sync should filter isLocalOnly categories if not Iranian IP', () async {
    final catLocal = Category(id: 1, name: 'Local', remoteUrl: 'url_local', source: 'src', isLocalOnly: true);
    final catGlobal = Category(id: 2, name: 'Global', remoteUrl: 'url_global', source: 'src', isLocalOnly: false);
    
    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => [catLocal, catGlobal]);
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

    when(() => mockDataSource.fetchFeed('url_global', 'src'))
        .thenAnswer((_) async => [itemGlobal]);

    await syncService.sync(false);

    final captured = verify(() => mockStorage.insertMany(captureAny())).captured;
    final insertedItems = captured.first as List<NewsItem>;
    expect(insertedItems.length, 1);
    expect(insertedItems.first.title, 'Global Title');
    
    verify(() => mockDataSource.fetchFeed('url_global', 'src')).called(1);
    verifyNever(() => mockDataSource.fetchFeed('url_local', 'src'));
  });

  test('sync should NOT filter isLocalOnly categories if Iranian IP', () async {
    final catLocal = Category(id: 1, name: 'Local', remoteUrl: 'url_local', source: 'src', isLocalOnly: true);
    
    when(() => mockStorage.getAllCategories()).thenAnswer((_) async => [catLocal]);
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

    when(() => mockDataSource.fetchFeed('url_local', 'src'))
        .thenAnswer((_) async => [itemLocal]);

    await syncService.sync(true);

    verify(() => mockDataSource.fetchFeed('url_local', 'src')).called(1);
    verify(() => mockStorage.insertMany(any())).called(1);
  });
}
