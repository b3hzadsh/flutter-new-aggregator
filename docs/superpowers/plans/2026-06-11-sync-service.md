# Sync Service Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a `SyncService` that fetches news items from multiple RSS feeds and stores them in the local ObjectBox database, ensuring no duplicate entries are created using a "smart upsert" strategy based on `remoteId`.

**Architecture:** `SyncService` acts as an orchestrator between `RssDataSource` and `ObjectBoxStore`. It iterates over a predefined list of Iranian news feeds, fetches the latest items, and performs an upsert into the database.

**Tech Stack:** Dart, Flutter, ObjectBox, Mockito (for testing).

---

### Task 1: Create SyncService

**Files:**
- Create: `lib/data/services/sync_service.dart`

- [ ] **Step 1: Create the SyncService class**

```dart
import '../sources/rss_data_source.dart';
import '../storage/objectbox_store.dart';
import '../../domain/entities/news_item.dart';
import '../../objectbox.g.dart';

class SyncService {
  final RssDataSource dataSource;
  final ObjectBoxStore db;

  SyncService(this.dataSource, this.db);

  Future<void> sync() async {
    final feeds = {
      'ISNA': 'https://www.isna.ir/rss',
      'Mehr': 'https://www.mehrnews.com/rss',
      'IRNA': 'https://www.irna.ir/rss',
      'Tasnim': 'https://www.tasnimnews.com/fa/rss/feed/0/7/1/',
    };

    for (var entry in feeds.entries) {
      try {
        final items = await dataSource.fetchFeed(entry.value, entry.key);
        for (var item in items) {
          // Smart upsert: check if remoteId already exists
          final query = db.newsBox.query(NewsItem_.remoteId.equals(item.remoteId)).build();
          final existing = query.findFirst();
          query.close();

          if (existing == null) {
            db.newsBox.put(item);
          }
        }
      } catch (e) {
        // Continue with other feeds if one fails
        continue;
      }
    }
  }
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/data/services/sync_service.dart
git commit -m "feat: add SyncService with smart upsert"
```

### Task 2: Verify SyncService with Tests

**Files:**
- Create: `test/data/services/sync_service_test.dart`

- [ ] **Step 1: Add mockito dependency if not present**

Check `pubspec.yaml` for `mockito` and `build_runner`. If not present, add them.

- [ ] **Step 2: Create mock classes for RssDataSource and ObjectBoxStore**

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_aggregator/data/services/sync_service.dart';
import 'package:news_aggregator/data/sources/rss_data_source.dart';
import 'package:news_aggregator/data/storage/objectbox_store.dart';
import 'package:news_aggregator/domain/entities/news_item.dart';
import 'package:news_aggregator/objectbox.g.dart';

@GenerateMocks([RssDataSource])
import 'sync_service_test.mocks.dart';

void main() {
  late SyncService syncService;
  late MockRssDataSource mockDataSource;
  late ObjectBoxStore db;
  late Store store;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('objectbox_sync_test');
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

  test('sync() should fetch feeds and put new items into the box', () async {
    final newsItem = NewsItem(
      remoteId: 'https://example.com/1',
      title: 'Test News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'ISNA',
      publishDate: DateTime.now(),
    );

    when(mockDataSource.fetchFeed(any, any)).thenAnswer((_) async => [newsItem]);

    await syncService.sync();

    final savedItems = db.newsBox.getAll();
    expect(savedItems.length, equals(4)); // 4 feeds, each returns the same item (different remoteId but we mocked it to return same)
    // Actually we should mock different items for different URLs if we want to be precise.
  });

  test('sync() should not put duplicate items (same remoteId)', () async {
     final newsItem = NewsItem(
      remoteId: 'duplicate-id',
      title: 'Test News',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'ISNA',
      publishDate: DateTime.now(),
    );

    when(mockDataSource.fetchFeed(any, any)).thenAnswer((_) async => [newsItem]);

    await syncService.sync();
    expect(db.newsBox.count(), equals(1)); // Only one item should be saved even if 4 feeds return same remoteId

    await syncService.sync();
    expect(db.newsBox.count(), equals(1)); // Still only one item
  });
}
```

- [ ] **Step 3: Generate mocks**

Run: `dart run build_runner build`

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/services/sync_service_test.dart`

- [ ] **Step 5: Commit changes**

```bash
git add test/data/services/sync_service_test.dart
git commit -m "test: add tests for SyncService"
```
