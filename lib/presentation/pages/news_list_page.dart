import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/news_cubit.dart';
import '../widgets/news_card.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCubit>().sync();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<NewsCubit>().sync(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              centerTitle: true,
              title: const Text('تازه‌ترین اخبار'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'جستجو...',
                    onChanged: (value) => context.read<NewsCubit>().search(value),
                    leading: const Icon(Icons.search),
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                            context.read<NewsCubit>().search('');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            BlocBuilder<NewsCubit, NewsState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state.error != null && state.items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('خطا در دریافت اطلاعات: ${state.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<NewsCubit>().sync(),
                            child: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.items.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('خبری یافت نشد')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return NewsCard(item: state.items[index]);
                    },
                    childCount: state.items.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
