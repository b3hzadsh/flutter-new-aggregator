import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/domain/entities/category.dart';
import 'package:news_aggregator/objectbox.g.dart';

class MockRssDataSource extends Mock implements RssDataSource {}

void main() {
  late Store store;
  late Directory tempDir;
  late ObjectBoxStore db;
  late MockRssDataSource mockDataSource;
  late SyncService syncService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_service_test');
    store = await openStore(directory: tempDir.path);
    db = ObjectBoxStore.fromStore(store);
    mockDataSource = MockRssDataSource();
    syncService = SyncService(mockDataSource, db);
  });

  tearDown(() async {
    store.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('sync should fetch items and store new ones with category association', () async {
    final category = Category(name: 'Test', remoteUrl: 'url', source: 'test');
    await db.seedCategories([category]);

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

    expect(db.newsBox.count(), 1);
    final stored = db.newsBox.getAll().first;
    expect(stored.remoteId, 'id1');
    expect(stored.category.target?.name, 'Test');
  });

  test('sync should avoid duplicates based on remoteId', () async {
    final category = Category(name: 'Test', remoteUrl: 'url', source: 'test');
    await db.seedCategories([category]);

    final existingItem = NewsItem(
      remoteId: 'id1',
      title: 'Old Title',
      content: 'Old Content',
      summary: 'Old Summary',
      sourceName: 'test',
      publishDate: DateTime.now(),
    );
    db.newsBox.put(existingItem);

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

    expect(db.newsBox.count(), 1);
    expect(db.newsBox.getAll().first.title, 'Old Title');
  });

  test('sync should handle multiple categories', () async {
    final cat1 = Category(name: 'Cat 1', remoteUrl: 'url1', source: 'src1');
    final cat2 = Category(name: 'Cat 2', remoteUrl: 'url2', source: 'src2');
    await db.seedCategories([cat1, cat2]);

    final item1 = NewsItem(
      remoteId: 'id1',
      title: 'Title 1',
      content: 'Content 1',
      summary: 'Summary 1',
      sourceName: 'src1',
      publishDate: DateTime.now(),
    );
    final item2 = NewsItem(
      remoteId: 'id2',
      title: 'Title 2',
      content: 'Content 2',
      summary: 'Summary 2',
      sourceName: 'src2',
      publishDate: DateTime.now(),
    );

    when(() => mockDataSource.fetchFeed('url1', 'src1'))
        .thenAnswer((_) async => [item1]);
    when(() => mockDataSource.fetchFeed('url2', 'src2'))
        .thenAnswer((_) async => [item2]);

    await syncService.sync(true);

    expect(db.newsBox.count(), 2);
    final storedItems = db.newsBox.getAll();
    expect(storedItems.any((i) => i.category.target?.name == 'Cat 1'), true);
    expect(storedItems.any((i) => i.category.target?.name == 'Cat 2'), true);
  });
}
