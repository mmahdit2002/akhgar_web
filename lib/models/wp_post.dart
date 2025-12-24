import 'wp_media.dart';

class WpPost {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final DateTime date;
  final List<WpMedia> media;

  WpPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    this.media = const [],
  });

  factory WpPost.fromJson(Map<String, dynamic> json) {
    final List<WpMedia> mediaList = [];
    final Set<String> addedUrls = {}; // To prevent duplicates

    // 1. Featured image
    final featured = json['_embedded']?['wp:featuredmedia']?[0];
    if (featured != null) {
      final url = featured['source_url'] as String?;
      if (url != null && url.isNotEmpty) {
        mediaList.add(WpMedia(url: url, type: 'image'));
        addedUrls.add(url);
      }
    }

    // 2. Attached media (Gallery)
    final attachments = json['_embedded']?['wp:attachment'] as List? ?? [];

    for (var att in attachments) {
      final url = att['source_url'] as String?;
      if (url == null || url.isEmpty) continue;

      // Skip if we already added this URL (deduplicate)
      if (addedUrls.contains(url)) continue;

      final mime = att['mime_type'] as String? ?? '';
      final type = mime.startsWith('video') ? 'video' : 'image';

      mediaList.add(WpMedia(url: url, type: type));
      addedUrls.add(url);
    }

    return WpPost(
      id: json['id'] as int,
      title: (json['title']?['rendered'] ?? '') as String,
      excerpt: ((json['excerpt']?['rendered'] ?? '') as String).replaceAll(RegExp(r'<[^>]*>'), ''),
      content: (json['content']?['rendered'] ?? '') as String,
      date: DateTime.parse(json['date'] as String),
      media: mediaList,
    );
  }
}
