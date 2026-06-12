# News Categories Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add category support to filter news by topic via a Sidebar/Drawer, with fixed RSS feed mappings.

**Architecture:** Use a `Category` ObjectBox entity with a `ToOne` relation from `NewsItem`. Seeding logic will ensure categories exist on startup. `NewsCubit` will manage filtered reactive streams.

**Tech Stack:** Flutter, flutter_bloc, ObjectBox.

---

### Task 1: Define Category Entity and Update NewsItem

**Files:**
- Create: `lib/domain/entities/category.dart`
- Modify: `lib/domain/entities/news_item.dart`

- [ ] **Step 1: Create Category entity**
```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class Category {
  @Id()
  int id = 0;

  @Index()
  final String name;
  
  @Unique()
  final String remoteUrl;
  
  final String source;

  Category({
    this.id = 0,
    required this.name,
    required this.remoteUrl,
    required this.source,
  });
}
```

- [ ] **Step 2: Update NewsItem entity**
Add `final category = ToOne<Category>();` to `NewsItem` class in `lib/domain/entities/news_item.dart`.

- [ ] **Step 3: Run build_runner**
Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Commit**
```bash
git add lib/domain/entities/category.dart lib/domain/entities/news_item.dart
git commit -m "feat: add Category entity and update NewsItem relation"
```

### Task 2: Update NewsStorage Repository and ObjectBoxStore

**Files:**
- Modify: `lib/domain/repositories/news_storage.dart`
- Modify: `lib/data/storage/objectbox_store.dart`

- [ ] **Step 1: Add Category methods to NewsStorage interface**
Add:
```dart
  Future<List<Category>> getAllCategories();
  Future<void> seedCategories(List<Category> categories);
  Stream<List<NewsItem>> watchItemsByCategory(int categoryId);
```

- [ ] **Step 2: Implement methods and seeding in ObjectBoxStore**
Update `lib/data/storage/objectbox_store.dart` to include `Box<Category> categoryBox` and implement the new methods.
Add a `_seedIfEmpty()` method called in `ObjectBoxStore.fromStore`.

- [ ] **Step 3: Commit**
```bash
git add lib/domain/repositories/news_storage.dart lib/data/storage/objectbox_store.dart
git commit -m "feat: implement Category storage and seeding"
```

### Task 3: Update SyncService for Dynamic Fetching

**Files:**
- Modify: `lib/data/services/sync_service.dart`

- [ ] **Step 1: Update SyncService.sync()**
Modify `sync()` to fetch all categories from `db` and use their `remoteUrl` and `name` for fetching and associating.

- [ ] **Step 2: Commit**
```bash
git add lib/data/services/sync_service.dart
git commit -m "feat: update SyncService to use Category entities"
```

### Task 4: Enhance NewsCubit for Filtering

**Files:**
- Modify: `lib/presentation/cubits/news_cubit.dart`

- [ ] **Step 1: Update NewsState and NewsCubit**
Add `selectedCategory` to `NewsState`.
Update `_subscribe()` to switch between `watchAllItems()` and `watchItemsByCategory()`.
Add `selectCategory(Category? category)`.

- [ ] **Step 2: Commit**
```bash
git add lib/presentation/cubits/news_cubit.dart
git commit -m "feat: add category filtering to NewsCubit"
```

### Task 5: Sidebar/Drawer UI

**Files:**
- Create: `lib/presentation/widgets/category_drawer.dart`
- Modify: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Create CategoryDrawer widget**
Implement a `Drawer` that displays categories in RTL.

- [ ] **Step 2: Add Drawer to NewsListPage**
Add the `CategoryDrawer` to the `Scaffold` in `NewsListPage`.

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/widgets/category_drawer.dart lib/presentation/pages/news_list_page.dart
git commit -m "feat: add Sidebar/Drawer for category navigation"
```
