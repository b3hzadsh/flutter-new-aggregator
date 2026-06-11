import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/objectbox.g.dart';

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

  test('ObjectBoxStore should be initialized correctly with an existing store', () {
    final objectBoxStore = ObjectBoxStore.fromStore(store);
    
    expect(objectBoxStore.store, equals(store));
    expect(objectBoxStore.newsBox, isNotNull);
    expect(objectBoxStore.newsBox.isEmpty(), isTrue);
  });
}
