# Enhanced News Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a suite of features including IP-based localized feeds, bookmarks, read status tracking, database clearing, dark mode, and connectivity alerts.

**Architecture:** Updates to ObjectBox entities, introduction of `NetworkService` and `ThemeCubit`, and enhancements to `SyncService` and `NewsCubit`. UI updates in `NewsListPage`, `NewsCard`, and `CategoryDrawer`.

**Tech Stack:** Flutter, flutter_bloc, ObjectBox, Dio, connectivity_plus, shared_preferences.

---

### Task 1: Setup Dependencies and Update Entities

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/domain/entities/news_item.dart`
- Modify: `lib/domain/entities/category.dart`

- [ ] **Step 1: Add new dependencies**
Add `connectivity_plus: ^6.0.3` and `shared_preferences: ^2.2.3` to `pubspec.yaml`.
Run: `flutter pub get`

- [ ] **Step 2: Update NewsItem entity**
Add `bool isBookmarked = false;` to `lib/domain/entities/news_item.dart`.

- [ ] **Step 3: Update Category entity**
Add `bool isLocalOnly = false;` to `lib/domain/entities/category.dart`.

- [ ] **Step 4: Run build_runner**
Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Commit**
```bash
git add pubspec.yaml lib/domain/entities/news_item.dart lib/domain/entities/category.dart
git commit -m "feat: add dependencies and update entities for enhanced features"
```

### Task 2: Implement Network and Connectivity Services

**Files:**
- Create: `lib/data/services/network_service.dart`

- [ ] **Step 1: Create NetworkService**
Implement `isIranianIp()` using `dio` to call `http://ip-api.com/json` and `hasInternet()` using `connectivity_plus`.

```dart
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Dio dio;
  final Connectivity connectivity;

  NetworkService(this.dio, this.connectivity);

  Future<bool> isIranianIp() async {
    try {
      final response = await dio.get('http://ip-api.com/json');
      return response.data['countryCode'] == 'IR';
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasInternet() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/data/services/network_service.dart
git commit -m "feat: implement NetworkService for IP and connectivity checks"
```

### Task 3: Implement Theme Management

**Files:**
- Create: `lib/presentation/cubits/theme_cubit.dart`
- Modify: `lib/presentation/theme/app_theme.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Update AppTheme**
Add a `darkTheme` to `lib/presentation/theme/app_theme.dart`.

- [ ] **Step 2: Create ThemeCubit**
Manage `ThemeMode` and persist via `shared_preferences`.

- [ ] **Step 3: Update main.dart**
Initialize `SharedPreferences` and provide `ThemeCubit`. Update `MaterialApp` to use `ThemeMode`.

- [ ] **Step 4: Commit**
```bash
git add lib/presentation/theme/app_theme.dart lib/presentation/cubits/theme_cubit.dart lib/main.dart
git commit -m "feat: implement ThemeCubit for dark mode support"
```

### Task 4: Enhance NewsStorage and ObjectBoxStore

**Files:**
- Modify: `lib/domain/repositories/news_storage.dart`
- Modify: `lib/data/storage/objectbox_store.dart`

- [ ] **Step 1: Add new methods to NewsStorage**
Add `clearAllNews()`, `updateNewsStatus()`, and `watchBookmarks()`.

- [ ] **Step 2: Implement in ObjectBoxStore**
Implement the new methods. `clearAllNews` should remove all items from `newsBox`.

- [ ] **Step 3: Commit**
```bash
git add lib/domain/repositories/news_storage.dart lib/data/storage/objectbox_store.dart
git commit -m "feat: enhance NewsStorage with clearing and bookmarking"
```

### Task 5: Localize SyncService and Connectivity Alerts

**Files:**
- Modify: `lib/data/services/sync_service.dart`
- Modify: `lib/presentation/cubits/news_cubit.dart`
- Modify: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Update SyncService.sync()**
Integrate `NetworkService.isIranianIp()` to filter categories before fetching.

- [ ] **Step 2: Update NewsCubit for connectivity**
Check `hasInternet()` before syncing. If no internet, emit a specific error state.

- [ ] **Step 3: Add Connectivity Popup**
Add a `BlocListener` in `NewsListPage` to show an `AlertDialog` on sync failure due to connectivity.

- [ ] **Step 4: Commit**
```bash
git add lib/data/services/sync_service.dart lib/presentation/cubits/news_cubit.dart lib/presentation/pages/news_list_page.dart
git commit -m "feat: add localized syncing and connectivity alerts"
```

### Task 6: Enhance NewsCubit and Card UI

**Files:**
- Modify: `lib/presentation/cubits/news_cubit.dart`
- Modify: `lib/presentation/widgets/news_card.dart`

- [ ] **Step 1: Add Cubit methods**
Add `toggleBookmark()`, `markAsRead()`, `clearDatabase()`, and `showBookmarksOnly()`.

- [ ] **Step 2: Update NewsCard UI**
Add `Opacity` for read items and a bookmark button.

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/cubits/news_cubit.dart lib/presentation/widgets/news_card.dart
git commit -m "feat: enhance NewsCubit and NewsCard for user states"
```

### Task 7: Update Sidebar/Drawer and NewsListPage

**Files:**
- Modify: `lib/presentation/widgets/category_drawer.dart`
- Modify: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Update CategoryDrawer**
Add "Saved News", "Dark Mode" switch, and "Clear History" button.

- [ ] **Step 2: Update NewsListPage**
Handle the "Saved News" view state and ensure the title reflects the current filter.

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/widgets/category_drawer.dart lib/presentation/pages/news_list_page.dart
git commit -m "feat: update Sidebar with bookmarks and theme toggle"
```
