import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/news_storage.dart';
import '../../domain/entities/category.dart';
import '../cubits/news_cubit.dart';

class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewsCubit>();
    final db = cubit.db;

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
              future: db.getAllCategories(),
              builder: (context, snapshot) {
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
                          selected: state.selectedCategory == null,
                          onTap: () {
                            cubit.selectCategory(null);
                            Navigator.pop(context);
                          },
                        ),
                        ...categories.map((category) => ListTile(
                              title: Text(category.name),
                              selected: state.selectedCategory?.id == category.id,
                              onTap: () {
                                cubit.selectCategory(category);
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
