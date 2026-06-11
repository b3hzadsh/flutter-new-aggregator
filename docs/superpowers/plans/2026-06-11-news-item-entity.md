# NewsItem Entity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the `NewsItem` ObjectBox entity in `lib/domain/entities/news_item.dart`.

**Architecture:** Domain layer entity annotated for ObjectBox persistence.

**Tech Stack:** Flutter, ObjectBox.

---

### Task 1: Create NewsItem Entity

**Files:**
- Create: `lib/domain/entities/news_item.dart`

- [ ] **Step 1: Create the directory if it doesn't exist**

Run: `mkdir -p lib/domain/entities/`

- [ ] **Step 2: Create news_item.dart with the entity definition**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class NewsItem {
  @Id()
  int id = 0;

  @Index(type: IndexType.hash)
  final String remoteId;

  @Index()
  final String title;
  
  final String content;
  final String summary;
  final String? imageUrl;
  final String sourceName;
  
  @Index()
  final DateTime publishDate;
  
  bool isRead;
  bool isPriority;

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
  });
}
```

- [ ] **Step 3: Commit the entity file**

```bash
git add lib/domain/entities/news_item.dart
git commit -m "feat: add NewsItem entity"
```

### Task 2: Generate ObjectBox Code

**Files:**
- Generate: `lib/objectbox.g.dart`

- [ ] **Step 1: Run build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `lib/objectbox.g.dart` is created or updated.

- [ ] **Step 2: Verify the generated code**

Check if `lib/objectbox.g.dart` exists and contains `NewsItem` metadata.
Run: `ls lib/objectbox.g.dart`

- [ ] **Step 3: Run flutter analyze to ensure no errors**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 4: Commit the generated code**

```bash
git add lib/objectbox.g.dart
git commit -m "feat: generate ObjectBox code for NewsItem"
```
