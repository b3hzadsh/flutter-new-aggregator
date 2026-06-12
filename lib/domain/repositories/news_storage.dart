import '../entities/news_item.dart';
import '../entities/category.dart';

abstract class NewsStorage {
  Future<void> insertMany(List<NewsItem> items);
  List<NewsItem> getAll();
  Set<String> getAllRemoteIds();
  Stream<List<NewsItem>> watchAllItems();
  Future<List<Category>> getAllCategories();
  Future<void> seedCategories(List<Category> categories);
  Stream<List<NewsItem>> watchItemsByCategory(int categoryId);
  Future<void> clearAllNews();
  Future<void> updateNewsStatus(int id, {bool? isRead, bool? isBookmarked});
  Stream<List<NewsItem>> watchBookmarks();
  Future<void> close();
}
