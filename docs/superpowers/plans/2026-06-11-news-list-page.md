# News List Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the main news list page and news card widgets with Hero transitions and RTL support.

**Architecture:** Use `BlocBuilder` to listen to `NewsCubit` state. Display news items in a `ListView.builder` for performance. Each item is a `NewsCard` which uses `Hero` for smooth transitions to the detail page (Task 9).

**Tech Stack:** Flutter, flutter_bloc, intl, Material 3.

---

## File Map

- **Presentation:**
  - `lib/presentation/widgets/news_card.dart`: Individual news item card.
  - `lib/presentation/pages/news_list_page.dart`: Main scrollable list page.

---

### Task 1: NewsCard Widget

**Files:**
- Create: `lib/presentation/widgets/news_card.dart`

- [ ] **Step 1: Implement NewsCard widget**
  - Use `Card` with `Material 3` style.
  - Include `Hero` widgets for the image and title.
  - Display `sourceName`, `summary`, and `publishDate` (formatted).
  - Use `Image.network` for the thumbnail.

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../domain/entities/news_item.dart';

class NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = intl.DateFormat.yMMMd('fa').format(item.publishDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              Hero(
                tag: 'image_${item.remoteId}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.sourceName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Hero(
                    tag: 'title_${item.remoteId}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.summary,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/widgets/news_card.dart
git commit -m "ui: implement NewsCard widget with Hero tags"
```

---

### Task 2: NewsListPage Widget

**Files:**
- Create: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Implement NewsListPage widget**
  - Use `BlocBuilder<NewsCubit, NewsState>`.
  - Use `RefreshIndicator` wrapping a `ListView.builder`.
  - Display `NewsCard` for each item.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/news_cubit.dart';
import '../widgets/news_card.dart';
import '../../data/services/sync_service.dart';

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خبرخوان'),
        centerTitle: true,
      ),
      body: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.items.isEmpty) {
            return Center(child: Text('خطا: ${state.error}'));
          }

          if (state.items.isEmpty) {
            return const Center(child: Text('خبری یافت نشد'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SyncService>().sync(),
            child: ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return NewsCard(
                  item: item,
                  onTap: () {
                    // Navigate to detail page (Task 9)
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/pages/news_list_page.dart
git commit -m "ui: implement NewsListPage with BlocBuilder and RefreshIndicator"
```

---

### Task 3: Integration with main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update main.dart to show NewsListPage**
  - Use `RepositoryProvider` for `SyncService`.
  - Use `BlocProvider` for `NewsCubit`.

- [ ] **Step 2: Commit**

```bash
git add lib/main.dart
git commit -m "feat: integrate NewsListPage and providers into main.dart"
```
