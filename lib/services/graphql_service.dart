import 'package:dio/dio.dart';

class GraphQLService {
  final Dio _dio;

  GraphQLService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://mashinsazi-akhgar.com/wordpress/graphql',
          headers: {'Content-Type': 'application/json'},
        ),
      );

  Future<Map<String, dynamic>> execute(String query, {Map<String, dynamic>? variables}) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'query': query,
          if (variables != null) 'variables': variables,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to execute GraphQL: ${response.statusCode}');
      }
      final data = response.data;
      if (data['errors'] != null) {
        throw Exception('GraphQL errors: ${data['errors']}');
      }
      return data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('GraphQL execution failed: $e');
    }
  }
}
