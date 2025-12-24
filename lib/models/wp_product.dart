class WpProduct {
  final int id;
  final String title;
  final String excerpt;
  final String? imageUrl;

  WpProduct({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
  });

  factory WpProduct.fromJson(Map<String, dynamic> json) {
    String? img;
    try {
      img = (json['_embedded']?['wp:featuredmedia']?[0]?['source_url']) as String?;
    } catch (_) {
      img = null;
    }

    return WpProduct(
      id: json['id'] as int,
      title: (json['title']?['rendered'] ?? '') as String,
      excerpt: ((json['excerpt']?['rendered'] ?? '') as String).replaceAll(RegExp(r'<[^>]*>'), ''),
      imageUrl: img,
    );
  }
}
