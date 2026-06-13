import 'package:dartz/dartz.dart';
import '../entities/news_item.dart';
import '../entities/category.dart';
import '../entities/feed_source.dart';
import '../../core/error/failures.dart';

abstract class NewsStorage {
  Future<void> insertMany(List<NewsItem> items);
  List<NewsItem> getAll();
  Set<String> getAllRemoteIds();
  Stream<List<NewsItem>> watchAllItems();
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<List<FeedSource>> getAllFeedSources();
  Future<void> syncCategoriesFromJson(String jsonPath);
  Stream<List<NewsItem>> watchItemsByCategory(String categoryRemoteId);
  Future<void> deleteOldNews(DateTime cutoff);
  Future<void> clearAllNews();
  Future<void> updateNewsStatus(int id, {bool? isRead, bool? isBookmarked});
  Stream<List<NewsItem>> watchBookmarks();
  Future<void> close();
}
