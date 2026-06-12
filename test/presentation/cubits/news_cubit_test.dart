import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/domain/entities/category.dart';
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
    expect(cubit.state.selectedCategoryId, isNull);
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
    final category1 = Category(id: 1, remoteId: 'tech', name: 'Tech');
    
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
    cubit.selectCategory(category1.remoteId);
    
    expect(cubit.state.selectedCategoryId, category1.remoteId);
    verify(() => mockStorage.watchItemsByCategory('tech')).called(1);

    categoryItemsController.add([item1]);
    await Future.delayed(Duration.zero);

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.title, 'Tech News');

    // Deselect category
    cubit.selectCategory(null);
    expect(cubit.state.selectedCategoryId, isNull);
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

  test('toggleBookmark calls storage', () async {
    final item = NewsItem(id: 1, remoteId: '1', title: 'T', content: 'C', summary: 'S', sourceName: 'SN', publishDate: DateTime.now());
    when(() => mockStorage.updateNewsStatus(1, isBookmarked: any(named: 'isBookmarked')))
        .thenAnswer((_) async {});

    await cubit.toggleBookmark(item);

    verify(() => mockStorage.updateNewsStatus(1, isBookmarked: true)).called(1);
  });

  test('markAsRead calls storage if not read', () async {
    final item = NewsItem(id: 1, remoteId: '1', title: 'T', content: 'C', summary: 'S', sourceName: 'SN', publishDate: DateTime.now(), isRead: false);
    when(() => mockStorage.updateNewsStatus(1, isRead: true)).thenAnswer((_) async {});

    await cubit.markAsRead(item);

    verify(() => mockStorage.updateNewsStatus(1, isRead: true)).called(1);
  });

  test('showBookmarksOnly updates state and switches stream', () {
    late StreamController<List<NewsItem>> bookmarkController;
    bookmarkController = StreamController<List<NewsItem>>.broadcast();
    when(() => mockStorage.watchBookmarks()).thenAnswer((_) => bookmarkController.stream);

    cubit.showBookmarksOnly(true);
    expect(cubit.state.isShowingBookmarks, isTrue);
    verify(() => mockStorage.watchBookmarks()).called(1);
    
    bookmarkController.close();
  });

  test('clearDatabase calls storage', () async {
    when(() => mockStorage.clearAllNews()).thenAnswer((_) async {});

    await cubit.clearDatabase();

    verify(() => mockStorage.clearAllNews()).called(1);
  });
}
