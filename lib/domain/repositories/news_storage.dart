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
  Future<void> close();
}
