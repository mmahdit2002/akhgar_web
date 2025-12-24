class WpReview {
  final int id;
  final String author;
  final String content;
  final DateTime date;
  final int rating; // Optional, defaults to 0 if not present

  WpReview({
    required this.id,
    required this.author,
    required this.content,
    required this.date,
    this.rating = 0,
  });

  factory WpReview.fromJson(Map<String, dynamic> json) {
    return WpReview(
      id: json['id'] as int? ?? 0,
      author: json['author_name'] ?? 'کاربر مهمان',
      content: (json['content']?['rendered'] ?? '').replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      // Some WP plugins return 'rating' field in comments
      rating: json['meta']?['rating'] != null ? int.tryParse(json['meta']['rating'].toString()) ?? 0 : 0,
    );
  }
}
