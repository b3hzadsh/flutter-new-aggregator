# News Cubit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a reactive `NewsCubit` that streams news items from ObjectBox and supports keyword searching.

**Architecture:** Use `flutter_bloc` for state management. `NewsCubit` will maintain an ObjectBox `StreamSubscription` to automatically update the UI when the database changes.

**Tech Stack:** Flutter, Bloc, ObjectBox.

---

### Task 1: Create NewsCubit

**Files:**
- Create: `lib/presentation/cubits/news_cubit.dart`

- [ ] **Step 1: Create the directory for cubits**

Run: `powershell -Command "New-Item -ItemType Directory -Force lib/presentation/cubits"`

- [ ] **Step 2: Implement NewsState and NewsCubit**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/entities/news_item.dart';
import '../../data/storage/objectbox_store.dart';
import '../../objectbox.g.dart';

class NewsState {
  final List<NewsItem> items;
  final bool isLoading;
  final String? error;

  NewsState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return NewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NewsCubit extends Cubit<NewsState> {
  final ObjectBoxStore db;
  StreamSubscription? _subscription;

  NewsCubit(this.db) : super(NewsState(items: [])) {
    _subscribe();
  }

  void _subscribe() {
    final query = db.newsBox
        .query()
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true);

    _subscription = query.listen((q) {
      final items = q.find();
      emit(state.copyWith(items: items));
    });
  }

  void search(String keyword) {
    _subscription?.cancel();
    
    if (keyword.isEmpty) {
      _subscribe();
      return;
    }

    final query = db.newsBox
        .query(NewsItem_.title.contains(keyword, caseSensitive: false)
            .or(NewsItem_.content.contains(keyword, caseSensitive: false)))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true);

    _subscription = query.listen((q) {
      emit(state.copyWith(items: q.find()));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 3: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues found.

### Task 2: Create NewsCubit Test

**Files:**
- Create: `test/presentation/cubits/news_cubit_test.dart`

- [ ] **Step 1: Create the test directory**

Run: `powershell -Command "New-Item -ItemType Directory -Force test/presentation/cubits"`

- [ ] **Step 2: Write tests for NewsCubit**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/presentation/cubits/news_cubit.dart';
import 'package:news_aggregator/objectbox.g.dart';
import 'dart:io';

void main() {
  late ObjectBoxStore store;
  late NewsCubit cubit;
  final testDir = Directory('test-db-cubit');

  setUp(() async {
    if (testDir.existsSync()) testDir.deleteSync(recursive: true);
    final obxStore = await openStore(directory: testDir.path);
    store = ObjectBoxStore.fromStore(obxStore);
    cubit = NewsCubit(store);
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
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/presentation/cubits/news_cubit_test.dart`
Expected: All tests pass.

### Task 3: Commit changes

- [ ] **Step 1: Commit everything**

Run: `git add . && git commit -m "feat: implement NewsCubit with tests"`
