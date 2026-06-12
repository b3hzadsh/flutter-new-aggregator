# Enhance NewsCubit and Card UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance the news aggregator with bookmarking, read tracking, and database management capabilities by updating the Cubit and NewsCard UI.

**Architecture:** Reactive Cubit pattern watching ObjectBox streams. UI reflects entity states (isRead, isBookmarked).

**Tech Stack:** Flutter, Bloc/Cubit, ObjectBox.

---

### Task 1: Enhance NewsState

**Files:**
- Modify: `lib/presentation/cubits/news_cubit.dart`

- [ ] **Step 1: Add isShowingBookmarks to NewsState**

```dart
class NewsState {
  final List<NewsItem> items;
  final bool isLoading;
  final String? error;
  final Category? selectedCategory;
  final bool isShowingBookmarks; // Add this

  NewsState({
    required this.items,
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.isShowingBookmarks = false, // Add this
  });

  NewsState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    String? error,
    Category? selectedCategory,
    bool clearCategory = false,
    bool? isShowingBookmarks, // Add this
  }) {
    return NewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isShowingBookmarks: isShowingBookmarks ?? this.isShowingBookmarks, // Add this
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/cubits/news_cubit.dart
git commit -m "feat: add isShowingBookmarks to NewsState"
```

---

### Task 2: Enhance NewsCubit Logic

**Files:**
- Modify: `lib/presentation/cubits/news_cubit.dart`

- [ ] **Step 1: Update _subscribe method**

```dart
  void _subscribe() {
    _subscription?.cancel();
    
    final Stream<List<NewsItem>> stream;
    if (state.isShowingBookmarks) {
      stream = db.watchBookmarks();
    } else if (state.selectedCategory != null) {
      stream = db.watchItemsByCategory(state.selectedCategory!.id);
    } else {
      stream = db.watchAllItems();
    }

    _subscription = stream.listen((items) {
      emit(state.copyWith(items: items));
    });
  }
```

- [ ] **Step 2: Add toggleBookmark, markAsRead, clearDatabase, and showBookmarksOnly methods**

```dart
  Future<void> toggleBookmark(NewsItem item) async {
    await db.updateNewsStatus(item.id, isBookmarked: !item.isBookmarked);
  }

  Future<void> markAsRead(NewsItem item) async {
    if (!item.isRead) {
      await db.updateNewsStatus(item.id, isRead: true);
    }
  }

  Future<void> clearDatabase() async {
    await db.clearAllNews();
  }

  void showBookmarksOnly(bool show) {
    emit(state.copyWith(isShowingBookmarks: show));
    _subscribe();
  }
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/cubits/news_cubit.dart
git commit -m "feat: add bookmarking and read tracking methods to NewsCubit"
```

---

### Task 3: Update NewsCard UI

**Files:**
- Modify: `lib/presentation/widgets/news_card.dart`

- [ ] **Step 1: Add Opacity for isRead status and Bookmark button**

```dart
class NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle; // Add this

  const NewsCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onBookmarkToggle, // Add this
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
        child: Opacity( // Add Opacity wrap
          opacity: item.isRead ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                // ... Hero and Image
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
                          // ... style
                        ),
                        Row( // Wrap date and bookmark in a Row
                          children: [
                            Text(
                              dateStr,
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                size: 20,
                                color: item.isBookmarked ? theme.colorScheme.primary : null,
                              ),
                              onPressed: onBookmarkToggle,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ... Title and Summary
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update NewsListPage to pass onBookmarkToggle**
- Modify: `lib/presentation/pages/news_list_page.dart`

```dart
// Inside ListView.builder in NewsListPage
NewsCard(
  item: item,
  onTap: () {
    context.read<NewsCubit>().markAsRead(item);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailPage(item: item),
      ),
    );
  },
  onBookmarkToggle: () {
    context.read<NewsCubit>().toggleBookmark(item);
  },
)
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/widgets/news_card.dart lib/presentation/pages/news_list_page.dart
git commit -m "feat: update NewsCard UI with read status and bookmarking"
```

---

### Task 4: Verify with Tests

**Files:**
- Modify: `test/presentation/cubits/news_cubit_test.dart`
- Create: `test/widget/presentation/widgets/news_card_test.dart`

- [ ] **Step 1: Add tests for new Cubit methods**

```dart
  test('toggleBookmark calls storage', () async {
    final item = NewsItem(id: 1, remoteId: '1', title: 'T', content: 'C', summary: 'S', sourceName: 'SN', publishDate: DateTime.now());
    when(() => mockStorage.updateNewsStatus(1, isBookmarked: any(named: 'isBookmarked')))
        .thenAnswer((_) async {});

    await cubit.toggleBookmark(item);

    verify(() => mockStorage.updateNewsStatus(1, isBookmarked: true)).called(1);
  });

  test('markAsRead calls storage if not read', () async {
    final item = NewsItem(id: 1, remoteId: '1', title: 'T', content: 'C', summary: 'S', sourceName: 'SN', publishDate: DateTime.now(), isRead: false);
    when(() => mockStorage.updateNewsStatus(1, isRead: true)).thenAnswer((_) async {});

    await cubit.markAsRead(item);

    verify(() => mockStorage.updateNewsStatus(1, isRead: true)).called(1);
  });

  test('showBookmarksOnly updates state and switches stream', () {
    late StreamController<List<NewsItem>> bookmarkController;
    bookmarkController = StreamController<List<NewsItem>>.broadcast();
    when(() => mockStorage.watchBookmarks()).thenAnswer((_) => bookmarkController.stream);

    cubit.showBookmarksOnly(true);
    expect(cubit.state.isShowingBookmarks, isTrue);
    verify(() => mockStorage.watchBookmarks()).called(1);
    
    bookmarkController.close();
  });
```

- [ ] **Step 2: Create widget test for NewsCard**

```dart
void main() {
  testWidgets('NewsCard shows bookmark icon and handles tap', (tester) async {
    final item = NewsItem(
      remoteId: '1',
      title: 'Title',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
      isBookmarked: false,
    );

    bool toggled = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NewsCard(
          item: item,
          onTap: () {},
          onBookmarkToggle: () => toggled = true,
        ),
      ),
    ));

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(toggled, isTrue);
  });

  testWidgets('NewsCard is dimmed when read', (tester) async {
    final item = NewsItem(
      remoteId: '1',
      title: 'Title',
      content: 'Content',
      summary: 'Summary',
      sourceName: 'Source',
      publishDate: DateTime.now(),
      isRead: true,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NewsCard(
          item: item,
          onTap: () {},
          onBookmarkToggle: () {},
        ),
      ),
    ));

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 0.5);
  });
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 4: Commit**

```bash
git add test/presentation/cubits/news_cubit_test.dart test/widget/presentation/widgets/news_card_test.dart
git commit -m "test: verify NewsCubit and NewsCard enhancements"
```
