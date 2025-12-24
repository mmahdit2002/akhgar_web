import 'wp_media.dart';

class WpTerm {
  final int id;
  final String name;
  final String? slug;
  final String? taxonomy;

  const WpTerm({
    required this.id,
    required this.name,
    this.slug,
    this.taxonomy,
  });

  factory WpTerm.fromJson(Map<String, dynamic> json) {
    return WpTerm(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      taxonomy: json['taxonomy']?.toString(),
    );
  }
}

class WpAttribute {
  final int id;
  final String name;
  final List<String> options;

  WpAttribute({required this.id, required this.name, required this.options});

  factory WpAttribute.fromJson(Map<String, dynamic> json) {
    return WpAttribute(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class WpProduct {
  final int id;
  final String title;
  final String excerpt;
  final String description; // Full content
  final String? slug;
  final String? status;
  final String? type;
  final String? link;
  final DateTime? date;
  final DateTime? modified;

  final List<WpTerm> categories;
  final List<WpTerm> tags;
  final List<WpTerm> brands;
  final List<WpAttribute> attributes; // For "Additional Info" tab
  final List<WpMedia> media;

  String? get imageUrl => media.isNotEmpty ? media.first.url : null;

  const WpProduct({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.description,
    required this.media,
    this.slug,
    this.status,
    this.type,
    this.link,
    this.date,
    this.modified,
    this.categories = const [],
    this.tags = const [],
    this.brands = const [],
    this.attributes = const [],
  });

  factory WpProduct.fromJson(Map<String, dynamic> json) {
    // 1. Media Parsing
    final List<WpMedia> mediaList = <WpMedia>[];
    final Set<String> addedUrls = <String>{};

    final featured = json['_embedded']?['wp:featuredmedia']?[0];
    if (featured is Map) {
      final String? url = featured['source_url']?.toString();
      if (url != null && url.isNotEmpty) {
        mediaList.add(WpMedia(url: url, type: 'image'));
        addedUrls.add(url);
      }
    }

    final gallery = json['product_gallery'];
    if (gallery is List) {
      for (final item in gallery) {
        if (item is Map) {
          final String? url = item['url']?.toString();
          final String type = (item['type'] ?? 'image').toString();
          if (url != null && url.isNotEmpty && !addedUrls.contains(url)) {
            mediaList.add(WpMedia(url: url, type: type));
            addedUrls.add(url);
          }
        }
      }
    }

    // 2. Term Parsing (Cats, Tags, Brands)
    final allTerms = _parseAllEmbeddedTerms(json);
    final categories = allTerms.where((t) => t.taxonomy == 'product_cat').toList();
    final tags = allTerms.where((t) => t.taxonomy == 'product_tag').toList();
    final brands = allTerms.where((t) => t.taxonomy == 'product_brand').toList();

    // 3. Attribute Parsing
    final List<WpAttribute> attrs = [];
    if (json['attributes'] != null && json['attributes'] is List) {
      for (var item in json['attributes']) {
        attrs.add(WpAttribute.fromJson(item));
      }
    }

    return WpProduct(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: (json['title']?['rendered'] ?? '').toString(),
      excerpt: _stripHtml((json['excerpt']?['rendered'] ?? '').toString()),
      description: _stripHtml((json['content']?['rendered'] ?? '').toString()),
      slug: json['slug']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      link: json['link']?.toString(),
      date: _parseDate(json['date']),
      modified: _parseDate(json['modified']),
      categories: categories,
      tags: tags,
      brands: brands,
      attributes: attrs,
      media: mediaList,
    );
  }

  static List<WpTerm> _parseAllEmbeddedTerms(Map<String, dynamic> json) {
    final root = json['_embedded']?['wp:term'];
    if (root is! List) return const [];
    final List<WpTerm> out = [];
    for (final group in root) {
      if (group is List) {
        for (final t in group) {
          if (t is Map<String, dynamic>) {
            out.add(WpTerm.fromJson(t));
          } else if (t is Map) {
            out.add(WpTerm.fromJson(Map<String, dynamic>.from(t)));
          }
        }
      }
    }
    return out;
  }

  static DateTime? _parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&').replaceAll('&quot;', '"').replaceAll('&#039;', "'").trim();
  }
}
