import 'package:objectbox/objectbox.dart';

@Entity()
class Category {
  @Id()
  int id = 0;

  @Index()
  final String name;
  
  @Unique()
  final String remoteUrl;
  
  final String source;
  bool isLocalOnly;

  Category({
    this.id = 0,
    required this.name,
    required this.remoteUrl,
    required this.source,
    this.isLocalOnly = false,
  });
}
