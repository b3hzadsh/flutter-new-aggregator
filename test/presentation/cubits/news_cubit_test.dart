import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'package:news_aggregator/objectbox.g.dart';
import 'dart:io';

class MockSyncService extends Mock implements SyncService {}

void main() {
  late ObjectBoxStore store;
  late NewsCubit cubit;
  late MockSyncService mockSyncService;
  final testDir = Directory('test-db-cubit');

  setUp(() async {
    if (testDir.existsSync()) testDir.deleteSync(recursive: true);
    final obxStore = await openStore(directory: testDir.path);
    store = ObjectBoxStore.fromStore(obxStore);
    mockSyncService = MockSyncService();
    cubit = NewsCubit(store, mockSyncService);
  });

  tearDown(() async {
    await cubit.close();
    store.close();
    if (testDir.existsSync()) testDir.deleteSync(recursive: true);
  });

  test('initial state has empty list', () {
    expect(cubit.state.items, isEmpty);
  });

  test('emits news items when database changes', () async {
    final item = NewsItem(
      remoteId: '1',
      title: 'Test News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );

    store.newsBox.put(item);

    // Wait for stream to emit
    await Future.delayed(const Duration(milliseconds: 100));

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.title, 'Test News');
  });

  test('search filters items', () async {
    final item1 = NewsItem(
      remoteId: '1',
      title: 'Flutter News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );
    final item2 = NewsItem(
      remoteId: '2',
      title: 'Dart News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );

    store.newsBox.putMany([item1, item2]);

    await Future.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.items.length, 2);

    cubit.search('Flutter');
    await Future.delayed(const Duration(milliseconds: 100));

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.title, 'Flutter News');
  });
}
