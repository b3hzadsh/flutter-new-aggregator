import '../../domain/entities/news_item.dart';

abstract class NewsStorage {
  Future<void> insertMany(List<NewsItem> items);
  List<NewsItem> getAll();
  Set<String> getAllRemoteIds();
  Stream<List<NewsItem>> watchAllItems();
  Future<void> close();
}
