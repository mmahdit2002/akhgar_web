class WpPost {
  final int id;
  final String title;
  final String excerpt;
  final DateTime date;

  WpPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.date,
  });

  factory WpPost.fromJson(Map<String, dynamic> json) {
    return WpPost(
      id: json['id'] as int,
      title: (json['title']?['rendered'] ?? '') as String,
      excerpt: ((json['excerpt']?['rendered'] ?? '') as String).replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      ),
      date: DateTime.parse(
        json['date'] as String,
      ),
    );
  }
}
