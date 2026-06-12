import 'package:flutter/foundation.dart';
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

  Future<void> sync(bool isIranianIp) async {
    final allCategories = await db.getAllCategories();
    final categories = allCategories.where((c) {
      if (c.isLocalOnly && !isIranianIp) return false;
      return true;
    }).toList();

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
        debugPrint('Error fetching feed for ${category.name}: $e');
      }
    }

    if (allNewItems.isNotEmpty) {
      await db.insertMany(allNewItems);
      debugPrint('Synced ${allNewItems.length} new items across ${categories.length} categories');
    }
  }
}
