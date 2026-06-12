# News Categories Hierarchy and Automatic Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a hierarchical category structure (Category -> FeedSource -> NewsItem) and an automatic 30-day cleanup mechanism for non-bookmarked news.

**Architecture:** Refactor `Category` entity, introduce `FeedSource`, update `NewsItem` relationship. Enhance `SyncService` for cleanup and hierarchical sync.

**Tech Stack:** Flutter, ObjectBox, BLoC (Cubit), Dio.

---

### Task 1: Update Entities

**Files:**
- Modify: `lib/domain/entities/category.dart`
- Create: `lib/domain/entities/feed_source.dart`
- Modify: `lib/domain/entities/news_item.dart`

- [ ] **Step 1: Update `Category` entity**

```dart
import 'package:objectbox/objectbox.dart';
import 'feed_source.dart';

@Entity()
class Category {
  @Id()
  int id = 0;

  @Unique()
  final String remoteId;

  @Index()
  final String name;

  @Backlink('category')
  final feeds = ToMany<FeedSource>();

  Category({
    this.id = 0,
    required this.remoteId,
    required this.name,
  });
}
```

- [ ] **Step 2: Create `FeedSource` entity**

```dart
import 'package:objectbox/objectbox.dart';
import 'category.dart';

@Entity()
class FeedSource {
  @Id()
  int id = 0;

  @Index()
  final String name;

  @Unique()
  final String url;

  final String language;
  final bool isLocalOnly;

  final category = ToOne<Category>();

  FeedSource({
    this.id = 0,
    required this.name,
    required this.url,
    required this.language,
    this.isLocalOnly = false,
  });
}
```

- [ ] **Step 3: Update `NewsItem` entity relationship**

```dart
import 'package:objectbox/objectbox.dart';
import 'feed_source.dart';

@Entity()
class NewsItem {
  @Id()
  int id = 0;

  final feedSource = ToOne<FeedSource>();

  @Index(type: IndexType.hash)
  final String remoteId;

  @Index()
  final String title;
  
  final String content;
  final String summary;
  final String? imageUrl;
  final String sourceName;
  
  @Index()
  @Property(type: PropertyType.date)
  final DateTime publishDate;
  
  bool isRead;
  bool isPriority;
  bool isBookmarked;

  NewsItem({
    this.id = 0,
    required this.remoteId,
    required this.title,
    required this.content,
    required this.summary,
    this.imageUrl,
    required this.sourceName,
    required this.publishDate,
    this.isRead = false,
    this.isPriority = false,
    this.isBookmarked = false,
  });
}
```

- [ ] **Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: PASS (generates `objectbox.g.dart`)

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/category.dart lib/domain/entities/feed_source.dart lib/domain/entities/news_item.dart
git commit -m "feat: refactor entities to hierarchical categories"
```

### Task 2: Update Repository Interface and ObjectBox implementation

**Files:**
- Modify: `lib/domain/repositories/news_storage.dart`
- Modify: `lib/data/storage/objectbox_store.dart`

- [ ] **Step 1: Update `NewsStorage` interface**

```dart
import '../entities/news_item.dart';
import '../entities/category.dart';
import '../entities/feed_source.dart';

abstract class NewsStorage {
  Future<void> insertMany(List<NewsItem> items);
  List<NewsItem> getAll();
  Set<String> getAllRemoteIds();
  Stream<List<NewsItem>> watchAllItems();
  Future<List<Category>> getAllCategories();
  Future<List<FeedSource>> getAllFeedSources();
  Future<void> syncCategoriesFromJson(String jsonPath);
  Future<void> deleteOldNews(DateTime cutoff);
  Stream<List<NewsItem>> watchItemsByCategory(String categoryRemoteId);
  Future<void> clearAllNews();
  Future<void> updateNewsStatus(int id, {bool? isRead, bool? isBookmarked});
  Stream<List<NewsItem>> watchBookmarks();
  Future<void> close();
}
```

- [ ] **Step 2: Implement `deleteOldNews` in `ObjectBoxStore`**

```dart
  @override
  Future<void> deleteOldNews(DateTime cutoff) async {
    final query = newsBox
        .query(NewsItem_.publishDate.lessThan(cutoff.millisecondsSinceEpoch)
            .and(NewsItem_.isBookmarked.equals(false)))
        .build();
    query.remove();
    query.close();
  }
```

- [ ] **Step 3: Implement JSON seeding logic in `ObjectBoxStore`**

```dart
  @override
  Future<void> syncCategoriesFromJson(String jsonPath) async {
    final file = File(jsonPath);
    if (!await file.exists()) return;

    final data = json.decode(await file.readAsString());
    final categoriesMap = data['categories'] as Map<String, dynamic>;

    for (final entry in categoriesMap.entries) {
      final catData = entry.value;
      final category = Category(
        remoteId: catData['id'],
        name: catData['name'],
      );

      // Upsert category
      final existingCat = categoryBox.query(Category_.remoteId.equals(category.remoteId)).build().findFirst();
      if (existingCat != null) category.id = existingCat.id;
      categoryBox.put(category);

      final feedsData = catData['feeds'] as List;
      for (final feedData in feedsData) {
        final feed = FeedSource(
          name: feedData['name'],
          url: feedData['url'],
          language: feedData['language'],
          isLocalOnly: feedData['region'] == 'ایران',
        );
        feed.category.target = category;

        // Upsert feed
        final feedBox = store.box<FeedSource>();
        final existingFeed = feedBox.query(FeedSource_.url.equals(feed.url)).build().findFirst();
        if (existingFeed != null) feed.id = existingFeed.id;
        feedBox.put(feed);
      }
    }
  }
```

- [ ] **Step 4: Update `watchItemsByCategory` and `getAllFeedSources`**

```dart
  @override
  Future<List<FeedSource>> getAllFeedSources() async {
    return store.box<FeedSource>().getAll();
  }

  @override
  Stream<List<NewsItem>> watchItemsByCategory(String categoryRemoteId) {
    final category = categoryBox.query(Category_.remoteId.equals(categoryRemoteId)).build().findFirst();
    if (category == null) return Stream.value([]);

    return newsBox
        .query(NewsItem_.feedSource.backlink(FeedSource_.category).equals(category.id))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }
```

- [ ] **Step 5: Commit**

```bash
git add lib/domain/repositories/news_storage.dart lib/data/storage/objectbox_store.dart
git commit -m "feat: implement cleanup and JSON seeding in ObjectBoxStore"
```

### Task 3: Update SyncService logic

**Files:**
- Modify: `lib/data/services/sync_service.dart`

- [ ] **Step 1: Update `sync` method**

```dart
  Future<void> sync(bool isIranianIp) async {
    // 1. Cleanup old news
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await db.deleteOldNews(cutoff);

    // 2. Fetch all feed sources
    final allFeeds = await db.getAllFeedSources();
    final activeFeeds = allFeeds.where((f) {
      if (f.isLocalOnly && !isIranianIp) return false;
      return true;
    }).toList();

    if (activeFeeds.isEmpty) return;

    final List<NewsItem> allNewItems = [];
    final existingRemoteIds = db.getAllRemoteIds();

    for (final feed in activeFeeds) {
      try {
        final items = await dataSource.fetchFeed(feed.url, feed.name);
        
        for (final item in items) {
          if (!existingRemoteIds.contains(item.remoteId)) {
            item.feedSource.target = feed;
            allNewItems.add(item);
          }
        }
      } catch (e) {
        debugPrint('Error fetching feed for ${feed.name}: $e');
      }
    }

    if (allNewItems.isNotEmpty) {
      await db.insertMany(allNewItems);
    }
  }
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/services/sync_service.dart
git commit -m "feat: update SyncService with cleanup and hierarchical sync"
```

### Task 4: UI Adjustments and Seeding Integration

**Files:**
- Modify: `lib/presentation/cubits/news_cubit.dart`
- Modify: `lib/presentation/widgets/category_drawer.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Integrate `syncCategoriesFromJson` in `main.dart` or `ObjectBoxStore` init**

- [ ] **Step 2: Update `NewsCubit` to use `String categoryRemoteId`**

- [ ] **Step 3: Update `CategoryDrawer` UI**

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: finalize UI integration and seeding for hierarchical categories"
```
