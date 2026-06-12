# Update SyncService for Dynamic Fetching Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `SyncService` to fetch news categories from the database and associate synced news items with their respective categories.

**Architecture:** `SyncService` will query `NewsStorage.getAllCategories()` instead of using a hardcoded map. For each category found, it will fetch news items via `RssDataSource`, filter for duplicates, and set the `category` relation on `NewsItem` before persisting.

**Tech Stack:** Dart, Flutter, ObjectBox, Mocktail (for testing).

---

### Task 1: Update SyncService.dart

**Files:**
- Modify: `lib/data/services/sync_service.dart`

- [ ] **Step 1: Remove hardcoded feeds and update constructor**

Update `SyncService` to remove the `feeds` map and its initialization.

```dart
class SyncService {
  final RssDataSource dataSource;
  final NewsStorage db;

  SyncService(this.dataSource, this.db);

  Future<void> sync() async {
    // Logic will be updated in next step
  }
}
```

- [ ] **Step 2: Update sync() logic to use dynamic categories**

Fetch categories from `db` and iterate through them to fetch news items.

```dart
  Future<void> sync() async {
    final categories = await db.getAllCategories();
    
    final List<NewsItem> allNewItems = [];
    final existingRemoteIds = db.getAllRemoteIds();

    for (final category in categories) {
      try {
        final items = await dataSource.fetchFeed(category.remoteUrl, category.source);
        
        for (final item in items) {
          if (!existingRemoteIds.contains(item.remoteId)) {
            item.category.target = category;
            allNewItems.add(item);
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error fetching feed for ${category.name}: $e');
      }
    }

    if (allNewItems.isNotEmpty) {
      await db.insertMany(allNewItems);
      // ignore: avoid_print
      print('Synced ${allNewItems.length} new items across ${categories.length} categories');
    }
  }
```

- [ ] **Step 3: Commit changes to SyncService**

```bash
git add lib/data/services/sync_service.dart
git commit -m "feat: update SyncService to use Category entities from database"
```

### Task 2: Update SyncService Tests

**Files:**
- Modify: `test/data/services/sync_service_test.dart`

- [ ] **Step 1: Update test setup to seed categories**

Update the `setUp` and tests to work with `Category` entities instead of the `feeds` map.

```dart
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_service_test');
    store = await openStore(directory: tempDir.path);
    db = ObjectBoxStore.fromStore(store);
    mockDataSource = MockRssDataSource();
    syncService = SyncService(mockDataSource, db); // Removed feeds param
  });
```

- [ ] **Step 2: Update 'sync should fetch items and store new ones' test**

```dart
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

    await syncService.sync();

    expect(db.newsBox.count(), 1);
    final stored = db.newsBox.getAll().first;
    expect(stored.remoteId, 'id1');
    expect(stored.category.target?.name, 'Test');
  });
```

- [ ] **Step 3: Update 'sync should avoid duplicates based on remoteId' test**

```dart
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

    await syncService.sync();

    expect(db.newsBox.count(), 1);
    expect(db.newsBox.getAll().first.title, 'Old Title');
  });
```

- [ ] **Step 4: Update 'sync should handle multiple feeds' test**

```dart
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

    await syncService.sync();

    expect(db.newsBox.count(), 2);
    final storedItems = db.newsBox.getAll();
    expect(storedItems.any((i) => i.category.target?.name == 'Cat 1'), true);
    expect(storedItems.any((i) => i.category.target?.name == 'Cat 2'), true);
  });
```

- [ ] **Step 5: Run tests and verify**

Run: `flutter test test/data/services/sync_service_test.dart`

- [ ] **Step 6: Commit test updates**

```bash
git add test/data/services/sync_service_test.dart
git commit -m "test: update SyncService tests for Category-based syncing"
```
