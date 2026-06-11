import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import '../../domain/entities/news_item.dart';

class RssDataSource {
  final Dio dio;
  RssDataSource({required this.dio});

  Future<List<NewsItem>> fetchFeed(String url, String sourceName) async {
    final response = await dio.get(url);
    return parseRss(response.data.toString(), sourceName);
  }

  List<NewsItem> parseRss(String xmlString, String sourceName) {
    final document = XmlDocument.parse(xmlString);
    final items = document.findAllElements('item');
    return items.map((node) {
      final title = node.findElements('title').first.innerText;
      final description = node.findElements('description').first.innerText;
      final link = node.findElements('link').first.innerText;
      return NewsItem(
        remoteId: link,
        title: title,
        content: description,
        summary: description.length > 100 ? "${description.substring(0, 100)}..." : description,
        sourceName: sourceName,
        publishDate: DateTime.now(), // Simplified for now
      );
    }).toList();
  }
}
