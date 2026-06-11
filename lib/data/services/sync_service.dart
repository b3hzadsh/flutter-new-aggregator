import '../sources/rss_data_source.dart';
import '../../domain/repositories/news_storage.dart';
import '../../domain/repositories/rss_parser.dart';
import '../../domain/entities/news_item.dart';

class SyncService {
  final RssDataSource dataSource;
  final NewsStorage db;
  final Map<String, String> feeds;

  SyncService(
    this.dataSource,
    this.db, {
    Map<String, String>? feeds,
  }) : feeds = feeds ??
            {
              'ISNA': 'https://www.isna.ir/rss',
              'Mehr': 'https://www.mehrnews.com/rss',
              'IRNA': 'https://www.irna.ir/rss',
              'Tasnim': 'https://www.tasnimnews.com/fa/rss/feed/0/7/1/',
            };

  Future<void> sync() async {
    final results = await Future.wait(
      feeds.entries.map((entry) async {
        try {
          return await dataSource.fetchFeed(entry.value, entry.key);
        } catch (e) {
          // ignore: avoid_print
          print('Error fetching feed ${entry.key}: $e');
          return <NewsItem>[];
        }
      }),
    );

    final allItems = results.expand((items) => items).toList();
    if (allItems.isEmpty) return;

    // Get all remoteIds from database to avoid duplicates
    final existingRemoteIds = db.getAllRemoteIds();

    final newItems =
        allItems.where((item) => !existingRemoteIds.contains(item.remoteId)).toList();

    if (newItems.isNotEmpty) {
      await db.insertMany(newItems);
      // ignore: avoid_print
      print('Synced ${newItems.length} new items');
    }
  }
}
