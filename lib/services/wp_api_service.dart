import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wp_post.dart';
import '../models/wp_product.dart';
import '../models/wp_review.dart'; // Ensure this file exists

class WpApiService {
  static const String wpBase = 'https://mashinsazi-akhgar.com';
  static const String apiBase = '$wpBase/wordpress/wp-json/wp/v2';

  final http.Client _client;

  WpApiService({http.Client? client}) : _client = client ?? http.Client();

  // ==========================================
  //                 PRODUCTS
  // ==========================================

  Future<List<WpProduct>> fetchFeaturedProducts({int perPage = 3}) async {
    final uri = Uri.parse('$apiBase/product?per_page=$perPage&featured=1&_embed');
    final res = await _client.get(uri);

    if (res.statusCode != 200) throw Exception('Failed to load featured products');

    final List data = jsonDecode(res.body);
    return data.map((e) => WpProduct.fromJson(e)).toList();
  }

  Future<List<WpProduct>> fetchProducts({int perPage = 20, int page = 1}) async {
    final uri = Uri.parse('$apiBase/product?per_page=$perPage&page=$page&_embed');
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      if (res.statusCode == 400 || res.statusCode == 404) return [];
      throw Exception('Failed to load products');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => WpProduct.fromJson(e)).toList();
  }

  Future<WpProduct> fetchProduct(int id) async {
    // Added _embed to get taxonomies (categories, brands, tags)
    final uri = Uri.parse('$apiBase/product/$id?_embed');
    final res = await _client.get(uri);

    if (res.statusCode != 200) throw Exception('Failed to load product details');

    final json = jsonDecode(res.body);
    return WpProduct.fromJson(json);
  }

  // ==========================================
  //                 REVIEWS
  // ==========================================

  Future<List<WpReview>> fetchReviews(int productId) async {
    try {
      // Fetch standard WP comments linked to this post ID
      final uri = Uri.parse('$apiBase/comments?post=$productId&per_page=20');
      final res = await _client.get(uri);

      if (res.statusCode != 200) {
        print('API Error (Reviews): ${res.statusCode}');
        return [];
      }

      final List data = jsonDecode(res.body);
      return data.map((e) => WpReview.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // ==========================================
  //                  POSTS
  // ==========================================

  Future<List<WpPost>> fetchPosts({int perPage = 12, int page = 1}) async {
    final uri = Uri.parse('$apiBase/posts?per_page=$perPage&page=$page&_embed');
    print('🔗 Fetching posts page $page: $uri');

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      if (res.statusCode == 400 || res.statusCode == 404) return [];
      throw Exception('Failed to load posts');
    }

    final List data = jsonDecode(res.body);
    print('✅ Loaded ${data.length} posts');
    return data.map((e) => WpPost.fromJson(e)).toList();
  }

  Future<List<WpPost>> fetchLatestPosts({int perPage = 3}) async {
    print('📰 Fetching latest $perPage posts...');
    final posts = await fetchPosts(perPage: perPage, page: 1);
    print('📰 Loaded ${posts.length} homepage posts');
    return posts;
  }

  Future<WpPost> fetchPost(int id) async {
    final uri = Uri.parse('$apiBase/posts/$id?_embed');
    print('🔗 Fetching post $id: $uri');

    final res = await _client.get(uri);

    if (res.statusCode != 200) throw Exception('Failed to load post');

    final json = jsonDecode(res.body);
    return WpPost.fromJson(json);
  }
}
