# Task 1: Setup Dependencies and Update Entities Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add necessary dependencies and update ObjectBox entities to support enhanced features.

**Architecture:** Update `pubspec.yaml` for new libraries and modify domain entities with new fields. Regenerate ObjectBox code to reflect entity changes.

**Tech Stack:** Flutter, ObjectBox, connectivity_plus, shared_preferences.

---

### Task 1: Add new dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add `connectivity_plus` and `shared_preferences`**

Add the following to `dependencies` in `pubspec.yaml`:
```yaml
  connectivity_plus: ^6.0.3
  shared_preferences: ^2.2.3
```

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: Success

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: add connectivity_plus and shared_preferences dependencies"
```

### Task 2: Update NewsItem entity

**Files:**
- Modify: `lib/domain/entities/news_item.dart`

- [ ] **Step 1: Add `isBookmarked` field**

```dart
<<<<
  bool isRead;
  bool isPriority;

  NewsItem({
====
  bool isRead;
  bool isPriority;
  bool isBookmarked;

  NewsItem({
>>>>
```

- [ ] **Step 2: Update constructor**

```dart
<<<<
    this.isRead = false,
    this.isPriority = false,
  });
}
====
    this.isRead = false,
    this.isPriority = false,
    this.isBookmarked = false,
  });
}
>>>>
```

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/news_item.dart
git commit -m "feat: add isBookmarked field to NewsItem entity"
```

### Task 3: Update Category entity

**Files:**
- Modify: `lib/domain/entities/category.dart`

- [ ] **Step 1: Add `isLocalOnly` field**

```dart
<<<<
  final String source;

  Category({
====
  final String source;
  bool isLocalOnly;

  Category({
>>>>
```

- [ ] **Step 2: Update constructor**

```dart
<<<<
    required this.remoteUrl,
    required this.source,
  });
}
====
    required this.remoteUrl,
    required this.source,
    this.isLocalOnly = false,
  });
}
>>>>
```

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/category.dart
git commit -m "feat: add isLocalOnly field to Category entity"
```

### Task 4: Regenerate ObjectBox code

- [ ] **Step 1: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `objectbox.g.dart` is updated successfully.

- [ ] **Step 2: Run tests to ensure no regressions**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/objectbox-model.json lib/objectbox.g.dart
git commit -m "chore: regenerate ObjectBox code for updated entities"
```
