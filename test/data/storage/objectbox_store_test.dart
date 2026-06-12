import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/objectbox.g.dart';
import 'package:news_aggregator/domain/entities/category.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';

void main() {
  late Store store;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('objectbox_test');
    store = await openStore(directory: tempDir.path);
  });

  tearDown(() async {
    store.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ObjectBoxStore should be initialized correctly with an existing store',
      () {
    final objectBoxStore = ObjectBoxStore.fromStore(store);

    expect(objectBoxStore.store, equals(store));
    expect(objectBoxStore.newsBox, isNotNull);
  });

  test('ObjectBoxStore should seed categories if empty', () async {
    final objectBoxStore = ObjectBoxStore.fromStore(store);
    final categories = await objectBoxStore.getAllCategories();
    expect(categories, hasLength(4));
    expect(categories.any((c) => c.name == 'ISNA'), isTrue);
  });

  test('watchItemsByCategory should return items for specific category',
      () async {
    final objectBoxStore = ObjectBoxStore.fromStore(store);
    final categories = await objectBoxStore.getAllCategories();
    final category = categories.first;

    final item = NewsItem(
      remoteId: '1',
      title: 'Test',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );
    item.category.target = category;
    await objectBoxStore.insertMany([item]);

    final stream = objectBoxStore.watchItemsByCategory(category.id);
    final results = await stream.first;
    expect(results, hasLength(1));
    expect(results.first.remoteId, '1');
  });

  test('clearAllNews should remove all news items but keep categories',
      () async {
    final objectBoxStore = ObjectBoxStore.fromStore(store);

    final item = NewsItem(
      remoteId: '1',
      title: 'Test',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );
    await objectBoxStore.insertMany([item]);

    expect(objectBoxStore.getAll(), hasLength(1));

    await objectBoxStore.clearAllNews();

    expect(objectBoxStore.getAll(), isEmpty);
    expect(await objectBoxStore.getAllCategories(), isNotEmpty);
  });

  test('updateNewsStatus should update isRead and isBookmarked', () async {
    final objectBoxStore = ObjectBoxStore.fromStore(store);

    final item = NewsItem(
      remoteId: '1',
      title: 'Test',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );
    await objectBoxStore.insertMany([item]);
    final id = objectBoxStore.getAll().first.id;

    await objectBoxStore.updateNewsStatus(id, isRead: true);
    expect(objectBoxStore.newsBox.get(id)?.isRead, isTrue);
    expect(objectBoxStore.newsBox.get(id)?.isBookmarked, isFalse);

    await objectBoxStore.updateNewsStatus(id, isBookmarked: true);
    expect(objectBoxStore.newsBox.get(id)?.isRead, isTrue);
    expect(objectBoxStore.newsBox.get(id)?.isBookmarked, isTrue);

    await objectBoxStore.updateNewsStatus(id,
        isRead: false, isBookmarked: false);
    expect(objectBoxStore.newsBox.get(id)?.isRead, isFalse);
    expect(objectBoxStore.newsBox.get(id)?.isBookmarked, isFalse);
  });

  test('watchBookmarks should only return bookmarked items', () async {
    final objectBoxStore = ObjectBoxStore.fromStore(store);

    final item1 = NewsItem(
      remoteId: '1',
      title: 'Test 1',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
      isBookmarked: true,
    );
    final item2 = NewsItem(
      remoteId: '2',
      title: 'Test 2',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
      isBookmarked: false,
    );
    await objectBoxStore.insertMany([item1, item2]);

    final stream = objectBoxStore.watchBookmarks();
    final results = await stream.first;
    expect(results, hasLength(1));
    expect(results.first.remoteId, '1');
  });
}
