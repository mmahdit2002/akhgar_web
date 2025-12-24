import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wp_post.dart';
import '../models/wp_product.dart';

class WpApiService {
  // آدرس دامنه وردپرس را اینجا بگذار
  static const String wpBase = 'https://mashinsazi-akhgar.com';
  static const String apiBase = '$wpBase/wordpress/wp-json/wp/v2';

  final http.Client _client;

  WpApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<WpProduct>> fetchFeaturedProducts({int perPage = 3}) async {
    final uri = Uri.parse('$apiBase/product?per_page=$perPage&_embed');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load products');
    }
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => WpProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WpProduct>> fetchAllProducts({int perPage = 20}) async {
    final uri = Uri.parse('$apiBase/product?per_page=$perPage&_embed');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load products');
    }
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => WpProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WpPost>> fetchLatestPosts({int perPage = 3}) async {
    final uri = Uri.parse('$apiBase/posts?per_page=$perPage');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load posts');
    }
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => WpPost.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WpProduct> fetchProduct(int id) async {
    final uri = Uri.parse('$apiBase/product/$id?_embed');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load product');
    }
    final Map<String, dynamic> data = jsonDecode(res.body) as Map<String, dynamic>;
    return WpProduct.fromJson(data);
  }

  Future<WpPost> fetchPost(int id) async {
    final uri = Uri.parse('$apiBase/posts/$id?_embed');
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to load post');

    final Map<String, dynamic> data = jsonDecode(res.body);
    return WpPost.fromJson(data);
  }
}
