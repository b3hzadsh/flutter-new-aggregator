import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/feed_source.dart';
import '../../domain/repositories/news_storage.dart';

class ObjectBoxStore implements NewsStorage {
  final Store store;
  final Box<NewsItem> newsBox;
  final Box<Category> categoryBox;
  final Box<FeedSource> feedSourceBox;

  ObjectBoxStore.fromStore(this.store)
    : newsBox = Box<NewsItem>(store),
      categoryBox = Box<Category>(store),
      feedSourceBox = Box<FeedSource>(store);

  static Future<ObjectBoxStore> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "news_db"));
    return ObjectBoxStore.fromStore(store);
  }

  @override
  Future<void> insertMany(List<NewsItem> items) async {
    newsBox.putMany(items);
  }

  @override
  List<NewsItem> getAll() {
    return newsBox.getAll();
  }

  @override
  Set<String> getAllRemoteIds() {
    final query = newsBox.query().build();
    final ids = query.property(NewsItem_.remoteId).find().toSet();
    query.close();
    return ids;
  }

  @override
  Stream<List<NewsItem>> watchAllItems() {
    return newsBox
        .query()
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return categoryBox.getAll();
  }

  @override
  Future<List<FeedSource>> getAllFeedSources() async {
    return feedSourceBox.getAll();
  }

  @override
  Future<void> syncCategoriesFromJson(String jsonPath) async {
    try {
      final jsonString = await rootBundle.loadString(jsonPath);
      final data = json.decode(jsonString);
      final categoriesMap = data['categories'] as Map<String, dynamic>;

      for (final entry in categoriesMap.entries) {
        final catData = entry.value;
        final category = Category(
          remoteId: catData['id'],
          name: catData['name'],
        );

        // Upsert category
        final catQuery = categoryBox
            .query(Category_.remoteId.equals(category.remoteId))
            .build();
        final existingCat = catQuery.findFirst();
        catQuery.close();
        
        if (existingCat != null) category.id = existingCat.id;
        categoryBox.put(category);

        final feedsData = catData['feeds'] as List;
        for (final feedData in feedsData) {
          final feed = FeedSource(
            name: feedData['name'],
            url: feedData['url'],
            language: feedData['language'],
            isLocalOnly: feedData['region'] == 'ایران',
          );
          feed.category.target = category;

          // Upsert feed
          final feedQuery = feedSourceBox
              .query(FeedSource_.url.equals(feed.url))
              .build();
          final existingFeed = feedQuery.findFirst();
          feedQuery.close();
          
          if (existingFeed != null) feed.id = existingFeed.id;
          feedSourceBox.put(feed);
        }
      }
    } catch (e) {
      debugPrint('Error syncing categories from JSON: $e');
    }
  }

  @override
  Stream<List<NewsItem>> watchItemsByCategory(String categoryRemoteId) {
    final query = categoryBox.query(Category_.remoteId.equals(categoryRemoteId)).build();
    final category = query.findFirst();
    query.close();
    
    if (category == null) return Stream.value([]);

    final qBuilder = newsBox.query();
    qBuilder.link(NewsItem_.feedSource, FeedSource_.category.equals(category.id));
    
    return qBuilder
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<void> deleteOldNews(DateTime cutoff) async {
    final query = newsBox
        .query(NewsItem_.publishDate.lessThan(cutoff.millisecondsSinceEpoch)
            .and(NewsItem_.isBookmarked.equals(false)))
        .build();
    query.remove();
    query.close();
  }

  @override
  Future<void> clearAllNews() async {
    newsBox.removeAll();
  }

  @override
  Future<void> updateNewsStatus(
    int id, {
    bool? isRead,
    bool? isBookmarked,
  }) async {
    final item = newsBox.get(id);
    if (item != null) {
      if (isRead != null) item.isRead = isRead;
      if (isBookmarked != null) item.isBookmarked = isBookmarked;
      newsBox.put(item);
    }
  }

  @override
  Stream<List<NewsItem>> watchBookmarks() {
    return newsBox
        .query(NewsItem_.isBookmarked.equals(true))
        .order(NewsItem_.publishDate, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<void> close() async => store.close();
}
