import '../sources/rss_data_source.dart';
import '../../domain/repositories/news_storage.dart';
import '../../domain/repositories/rss_parser.dart';
import '../../domain/entities/news_item.dart';

class SyncService {
  final RssDataSource dataSource;
  final NewsStorage db;

  SyncService(
    this.dataSource,
    this.db,
  );

  Future<void> sync() async {
    final categories = await db.getAllCategories();
    if (categories.isEmpty) return;

    final List<NewsItem> allNewItems = [];
    final existingRemoteIds = db.getAllRemoteIds();

    for (final category in categories) {
      try {
        final items = await dataSource.fetchFeed(category.remoteUrl, category.source);
        
        for (final item in items) {
          if (!existingRemoteIds.contains(item.remoteId)) {
            item.category.target = category;
            allNewItems.add(item);
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error fetching feed for ${category.name}: $e');
      }
    }

    if (allNewItems.isNotEmpty) {
      await db.insertMany(allNewItems);
      // ignore: avoid_print
      print('Synced ${allNewItems.length} new items across ${categories.length} categories');
    }
  }
}
