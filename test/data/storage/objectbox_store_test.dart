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
}
