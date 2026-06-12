# Category Storage and Seeding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `NewsStorage` and `ObjectBoxStore` to support `Category` management, including seeding default categories and filtering news items by category.

**Architecture:** Extend the existing Clean Architecture repository interface and its ObjectBox implementation. Use ObjectBox `ToOne` and `ToMany` relations (indirectly via `category` field in `NewsItem`) to support category-based queries.

**Tech Stack:** Flutter, ObjectBox, Dart.

---

### Task 1: Update NewsStorage Interface

**Files:**
- Modify: `lib/domain/repositories/news_storage.dart`

- [ ] **Step 1: Add Category methods to NewsStorage interface**

Add the following methods to `NewsStorage`:
```dart
  Future<List<Category>> getAllCategories();
  Future<void> seedCategories(List<Category> categories);
  Stream<List<NewsItem>> watchItemsByCategory(int categoryId);
```
Also ensure `Category` and `NewsItem` are imported.

- [ ] **Step 2: Commit**
```bash
git add lib/domain/repositories/news_storage.dart
git commit -m "feat: add category methods to NewsStorage interface"
```

### Task 2: Implement Category methods in ObjectBoxStore

**Files:**
- Modify: `lib/data/storage/objectbox_store.dart`
- Test: `test/data/storage/objectbox_store_test.dart`

- [ ] **Step 1: Update ObjectBoxStore with categoryBox and new methods**

```dart
class ObjectBoxStore implements NewsStorage {
  late final Store store;
  late final Box<NewsItem> newsBox;
  late final Box<Category> categoryBox; // Add this

  ObjectBoxStore.fromStore(this.store) {
    newsBox = Box<NewsItem>(store);
    categoryBox = Box<Category>(store); // Initialize this
    _seedIfEmpty(); // Call seeding
  }

  // ... existing methods ...

  @override
  Future<List<Category>> getAllCategories() async {
    return categoryBox.getAll();
  }

  @override
  Future<void> seedCategories(List<Category> categories) async {
    categoryBox.putMany(categories);
  }

  @override
  Stream<List<NewsItem>> watchItemsByCategory(int categoryId) {
    return newsBox
        .query(NewsItem_.category.equals(categoryId))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  void _seedIfEmpty() {
    if (categoryBox.isEmpty()) {
      final defaults = [
        Category(name: 'ISNA', remoteUrl: 'https://www.isna.ir/rss', source: 'ISNA'),
        Category(name: 'Mehr', remoteUrl: 'https://www.mehrnews.com/rss', source: 'Mehr'),
        Category(name: 'IRNA', remoteUrl: 'https://www.irna.ir/rss', source: 'IRNA'),
        Category(name: 'Tasnim', remoteUrl: 'https://www.tasnimnews.com/fa/rss/feed/0/7/1/', source: 'Tasnim'),
      ];
      categoryBox.putMany(defaults);
    }
  }
}
```

- [ ] **Step 2: Update tests to verify seeding and new methods**

Modify `test/data/storage/objectbox_store_test.dart`:
```dart
  test('ObjectBoxStore should seed categories if empty', () {
    final objectBoxStore = ObjectBoxStore.fromStore(store);
    final categories = objectBoxStore.getAllCategories();
    expect(categories, completion(hasLength(4)));
  });

  test('watchItemsByCategory should return items for specific category', () async {
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
```

- [ ] **Step 3: Run tests**
Run: `flutter test test/data/storage/objectbox_store_test.dart`

- [ ] **Step 4: Commit**
```bash
git add lib/data/storage/objectbox_store.dart test/data/storage/objectbox_store_test.dart
git commit -m "feat: implement Category storage and seeding in ObjectBoxStore"
```
