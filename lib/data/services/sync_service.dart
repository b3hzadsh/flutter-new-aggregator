import 'package:flutter/foundation.dart';
import '../sources/rss_data_source.dart';
import '../../domain/repositories/news_storage.dart';
import '../../domain/entities/news_item.dart';

class SyncService {
  final RssDataSource dataSource;
  final NewsStorage db;

  SyncService(
    this.dataSource,
    this.db,
  );

  Future<void> sync(bool isIranianIp) async {
    // 1. Cleanup old news
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await db.deleteOldNews(cutoff);

    // 2. Fetch all feed sources
    final allFeeds = await db.getAllFeedSources();
    final activeFeeds = allFeeds.where((f) {
      if (f.isLocalOnly && !isIranianIp) return false;
      return true;
    }).toList();

    if (activeFeeds.isEmpty) return;

    final List<NewsItem> allNewItems = [];
    final existingRemoteIds = db.getAllRemoteIds();

    for (final feed in activeFeeds) {
      try {
        final items = await dataSource.fetchFeed(feed.url, feed.name);
        
        for (final item in items) {
          if (existingRemoteIds.add(item.remoteId)) {
            item.feedSource.target = feed;
            allNewItems.add(item);
          }
        }
      } catch (e) {
        debugPrint('Error fetching feed for ${feed.name}: $e');
      }
    }

    if (allNewItems.isNotEmpty) {
      await db.insertMany(allNewItems);
      debugPrint('Synced ${allNewItems.length} new items across ${activeFeeds.length} feeds');
    }
  }
}
