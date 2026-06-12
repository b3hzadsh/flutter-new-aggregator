import 'package:objectbox/objectbox.dart';
import 'category.dart';

@Entity()
class NewsItem {
  @Id()
  int id = 0;

  final category = ToOne<Category>();

  @Index(type: IndexType.hash)
  final String remoteId;

  @Index()
  final String title;
  
  final String content;
  final String summary;
  final String? imageUrl;
  final String sourceName;
  
  @Index()
  @Property(type: PropertyType.date)
  final DateTime publishDate;
  
  bool isRead;
  bool isPriority;

  NewsItem({
    this.id = 0,
    required this.remoteId,
    required this.title,
    required this.content,
    required this.summary,
    this.imageUrl,
    required this.sourceName,
    required this.publishDate,
    this.isRead = false,
    this.isPriority = false,
  });
}
