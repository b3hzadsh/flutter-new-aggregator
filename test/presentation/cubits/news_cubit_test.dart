import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/domain/entities/category.dart';
import 'package:news_aggregator/domain/repositories/news_storage.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'dart:async';
import '../../mocks.dart';

class MockSyncService extends Mock implements SyncService {}

void main() {
  late MockNewsStorage mockStorage;
  late MockSyncService mockSyncService;
  late MockNetworkService mockNetworkService;
  late NewsCubit cubit;
  late StreamController<List<NewsItem>> allItemsController;
  late StreamController<List<NewsItem>> categoryItemsController;

  setUp(() {
    mockStorage = MockNewsStorage();
    mockSyncService = MockSyncService();
    mockNetworkService = MockNetworkService();
    allItemsController = StreamController<List<NewsItem>>.broadcast();
    categoryItemsController = StreamController<List<NewsItem>>.broadcast();

    when(() => mockStorage.watchAllItems()).thenAnswer((_) => allItemsController.stream);
    when(() => mockStorage.watchItemsByCategory(any())).thenAnswer((_) => categoryItemsController.stream);
    when(() => mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(() => mockNetworkService.isIranianIp()).thenAnswer((_) async => true);

    cubit = NewsCubit(mockStorage, mockSyncService, mockNetworkService);
  });

  tearDown(() async {
    await cubit.close();
    await allItemsController.close();
    await categoryItemsController.close();
  });

  test('initial state has empty list', () {
    expect(cubit.state.items, isEmpty);
    expect(cubit.state.selectedCategory, isNull);
  });

  test('emits news items when database changes (all items)', () async {
    final item = NewsItem(
      remoteId: '1',
      title: 'Test News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );

    allItemsController.add([item]);

    // Wait for stream to emit
    await Future.delayed(Duration.zero);

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.title, 'Test News');
  });

  test('filters items by category', () async {
    final category1 = Category(id: 1, name: 'Tech', remoteUrl: 'url1', source: 'source1');
    
    final item1 = NewsItem(
      remoteId: '1',
      title: 'Tech News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
    );

    // Initial state: watching all
    verify(() => mockStorage.watchAllItems()).called(1);

    // Select category
    cubit.selectCategory(category1);
    
    expect(cubit.state.selectedCategory, category1);
    verify(() => mockStorage.watchItemsByCategory(1)).called(1);

    categoryItemsController.add([item1]);
    await Future.delayed(Duration.zero);

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.title, 'Tech News');

    // Deselect category
    cubit.selectCategory(null);
    expect(cubit.state.selectedCategory, isNull);
    verify(() => mockStorage.watchAllItems()).called(1); // Second call
  });

  test('sync updates loading state', () async {
    when(() => mockSyncService.sync(any())).thenAnswer((_) async {});

    final syncFuture = cubit.sync();

    expect(cubit.state.isLoading, isTrue);

    await syncFuture;

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.error, isNull);
    verify(() => mockSyncService.sync(any())).called(1);
  });

  test('sync handles error', () async {
    when(() => mockSyncService.sync(any())).thenThrow(Exception('Sync failed'));

    await cubit.sync();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.error, contains('Sync failed'));
  });

  test('sync handles no internet', () async {
    when(() => mockNetworkService.hasInternet()).thenAnswer((_) async => false);

    await cubit.sync();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.error, equals('NO_INTERNET'));
    verifyNever(() => mockSyncService.sync(any()));
  });
}
