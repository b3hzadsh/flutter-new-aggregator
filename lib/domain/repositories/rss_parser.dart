import '../../domain/entities/news_item.dart';

abstract class RssParser {
  List<NewsItem> parse(String xmlString, String sourceName);
}
