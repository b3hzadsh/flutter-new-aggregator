# CategoryDrawer and NewsListPage Updates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the sidebar and main news list page to support bookmark filtering, theme toggling, and data clearing.

**Architecture:** UI updates to existing Flutter widgets, interacting with `NewsCubit` and `ThemeCubit`.

**Tech Stack:** Flutter, BLoC (Cubit).

---

### Task 1: Update CategoryDrawer UI and Logic

**Files:**
- Modify: `lib/presentation/widgets/category_drawer.dart`

- [ ] **Step 1: Add ThemeCubit and new UI elements to CategoryDrawer**

```dart
// lib/presentation/widgets/category_drawer.dart

// ... existing imports ...
import '../cubits/theme_cubit.dart';

// ... in build method ...
final themeCubit = context.read<ThemeCubit>();

// ... in ListView children ...
Divider(),
ListTile(
  leading: const Icon(Icons.bookmark),
  title: const Text('اخبار ذخیره شده'),
  selected: state.isShowingBookmarks,
  onTap: () {
    cubit.showBookmarksOnly(true);
    Navigator.pop(context);
  },
),
BlocBuilder<ThemeCubit, ThemeMode>(
  builder: (context, mode) {
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode),
      title: const Text('حالت شب'),
      value: mode == ThemeMode.dark,
      onChanged: (_) => themeCubit.toggleTheme(),
    );
  },
),
Divider(),
ListTile(
  leading: Icon(Icons.delete_sweep, color: Theme.of(context).colorScheme.error),
  title: Text('پاک کردن تاریخچه', style: TextStyle(color: Theme.of(context).colorScheme.error)),
  onTap: () {
    cubit.clearDatabase();
    Navigator.pop(context);
  },
),
```

- [ ] **Step 2: Ensure Category selection resets bookmark filter**
Update `selectCategory` call to also reset bookmark filter if needed, but `NewsCubit.selectCategory` already handles its state. However, to be explicit in the UI:
```dart
onTap: () {
  cubit.showBookmarksOnly(false); // Reset bookmark filter when selecting category
  cubit.selectCategory(category);
  Navigator.pop(context);
},
```

- [ ] **Step 3: Commit changes**

```bash
git add lib/presentation/widgets/category_drawer.dart
git commit -m "feat: add bookmarks, theme toggle, and clear history to drawer"
```

---

### Task 2: Update NewsListPage Title

**Files:**
- Modify: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Update the AppBar title logic**

```dart
// lib/presentation/pages/news_list_page.dart

// ... in SliverAppBar title ...
title: Text(
  state.isShowingBookmarks
      ? 'اخبار ذخیره شده'
      : (state.selectedCategory?.name ?? 'تازه‌ترین اخبار'),
),
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/presentation/pages/news_list_page.dart
git commit -m "feat: update news list title based on filter"
```

---

### Task 3: Verification

- [ ] **Step 1: Run tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 2: Manual Check**
1. Open drawer.
2. Select "Saved News". Title should change to "اخبار ذخیره شده".
3. Toggle "Dark Mode". App theme should change.
4. Tap "Clear History". List should be cleared.
5. Select a category. Title should update and bookmark filter should be off.
