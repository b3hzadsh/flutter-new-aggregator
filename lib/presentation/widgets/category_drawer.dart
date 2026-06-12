import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../cubits/news_cubit.dart';
import '../cubits/theme_cubit.dart';

class CategoryDrawer extends StatefulWidget {
  const CategoryDrawer({super.key});

  @override
  State<CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  late final Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = context.read<NewsCubit>().db.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewsCubit>();
    final themeCubit = context.read<ThemeCubit>();

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
                    ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطا در بارگذاری دسته‌بندی‌ها: ${snapshot.error}', textAlign: TextAlign.center),
                  );
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!;
                return BlocBuilder<NewsCubit, NewsState>(
                  builder: (context, state) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          title: const Text('همه اخبار'),
                          selected: state.selectedCategoryId == null && !state.isShowingBookmarks,
                          onTap: () {
                            cubit.showBookmarksOnly(false);
                            cubit.selectCategory(null);
                            Navigator.pop(context);
                          },
                        ),
                        ...categories.map((category) => ListTile(
                              title: Text(category.name),
                              selected:
                                  state.selectedCategoryId == category.slug && !state.isShowingBookmarks,
                              onTap: () {
                                cubit.showBookmarksOnly(false);
                                cubit.selectCategory(category.slug, categoryName: category.name);
                                Navigator.pop(context);
                              },
                            )),
                        const Divider(),
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
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.delete_sweep,
                              color: Theme.of(context).colorScheme.error),
                          title: Text('پاک کردن تاریخچه',
                              style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('حذف تاریخچه'),
                                content: const Text(
                                    'آیا از حذف تمامی اخبار و نشان‌شده‌ها اطمینان دارید؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('انصراف'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      cubit.clearDatabase();
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Close drawer
                                    },
                                    child: Text('حذف',
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
