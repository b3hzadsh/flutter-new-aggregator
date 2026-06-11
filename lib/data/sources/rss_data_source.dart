import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import '../../domain/entities/news_item.dart';

class RssDataSource {
  final Dio dio;
  RssDataSource({required this.dio});

  Future<List<NewsItem>> fetchFeed(String url, String sourceName) async {
    try {
      final response = await dio.get(url);
      return parseRss(response.data.toString(), sourceName);
    } catch (e) {
      // Log or handle error appropriately in a real app
      return [];
    }
  }

  List<NewsItem> parseRss(String xmlString, String sourceName) {
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');
      return items.map((node) {
        final title = node.findElements('title').firstOrNull?.innerText ?? '';
        final description = node.findElements('description').firstOrNull?.innerText ?? '';
        final link = node.findElements('link').firstOrNull?.innerText ?? '';
        final pubDateStr = node.findElements('pubDate').firstOrNull?.innerText;

        final content = _stripHtml(description);
        final summary = content.length > 150 ? "${content.substring(0, 150)}..." : content;

        return NewsItem(
          remoteId: link,
          title: title,
          content: content,
          summary: summary,
          sourceName: sourceName,
          publishDate: _parseDate(pubDateStr),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  DateTime _parseDate(String? dateString) {
    if (dateString == null) return DateTime.now();
    try {
      // RSS 2.0 format: EEE, dd MMM yyyy HH:mm:ss Z
      // Example: Mon, 11 Jun 2026 12:00:00 +0330
      // DateFormat from intl is useful but RSS dates can vary.
      // We'll use a common pattern and fallback to tryParse.
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z");
      return format.parse(dateString);
    } catch (e) {
      return DateTime.tryParse(dateString) ?? DateTime.now();
    }
  }
}
