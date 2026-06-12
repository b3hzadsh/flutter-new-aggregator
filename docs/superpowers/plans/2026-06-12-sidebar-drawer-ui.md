# Sidebar/Drawer UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a Sidebar/Drawer for category navigation in RTL format, allowing users to filter news by source.

**Architecture:** Use a `Drawer` widget in the `Scaffold` of `NewsListPage`. The drawer will fetch categories from `NewsStorage` and interact with `NewsCubit` to update the selected category.

**Tech Stack:** Flutter, flutter_bloc, ObjectBox.

---

### Task 1: Create CategoryDrawer Widget

**Files:**
- Create: `lib/presentation/widgets/category_drawer.dart`

- [ ] **Step 1: Implement CategoryDrawer widget**
Create a new file `lib/presentation/widgets/category_drawer.dart` that uses a `FutureBuilder` to fetch categories from the database and displays them in a `Drawer`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../cubits/news_cubit.dart';

class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                'دسته‌بندی‌ها',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<NewsCubit, NewsState>(
              builder: (context, state) {
                return FutureBuilder<List<Category>>(
                  future: context.read<NewsCubit>().db.getAllCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data!;
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          title: const Text('همه اخبار'),
                          leading: const Icon(Icons.all_inclusive),
                          selected: state.selectedCategory == null,
                          onTap: () {
                            context.read<NewsCubit>().selectCategory(null);
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(),
                        ...categories.map((category) => ListTile(
                              title: Text(category.name),
                              leading: const Icon(Icons.category_outlined),
                              selected: state.selectedCategory?.id == category.id,
                              onTap: () {
                                context.read<NewsCubit>().selectCategory(category);
                                Navigator.pop(context);
                              },
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/widgets/category_drawer.dart
git commit -m "feat: implement CategoryDrawer widget"
```

### Task 2: Integrate Drawer into NewsListPage

**Files:**
- Modify: `lib/presentation/pages/news_list_page.dart`

- [ ] **Step 1: Add CategoryDrawer to NewsListPage**
Update `lib/presentation/pages/news_list_page.dart` to include the `CategoryDrawer` in the `Scaffold` and update the `AppBar` title based on the selected category.

```dart
// ... inside NewsListPage build method
return Scaffold(
  drawer: const CategoryDrawer(), // Add this line
  body: RefreshIndicator(
    // ...
  ),
);
```

Update the title:
```dart
// ... inside NewsListPage build method
BlocBuilder<NewsCubit, NewsState>(
  builder: (context, state) {
    final title = state.selectedCategory?.name ?? 'تازه‌ترین اخبار';
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          // ...
          title: Text(title),
          // ...
        ),
        // ...
      ],
    );
  },
),
```

- [ ] **Step 2: Verify RTL support**
Ensure that the `MaterialApp` in `main.dart` (or wherever it's defined) has `localizationsDelegates` and `supportedLocales` set up for Persian (fa/IR) to ensure the Drawer opens from the right.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/pages/news_list_page.dart
git commit -m "feat: integrate CategoryDrawer into NewsListPage"
```
