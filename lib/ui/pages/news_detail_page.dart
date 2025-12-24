import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mashinsazi_akhgar_web/models/wp_post.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';

class NewsDetailPage extends StatefulWidget {
  final int postId;
  const NewsDetailPage({super.key, required this.postId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late Future<WpPost> _postFuture;
  final WpApiService _api = WpApiService();

  @override
  void initState() {
    super.initState();
    _postFuture = _api.fetchPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeCubit c) => c.isDark);
    final bg = isDark ? WebColors.darkBg : WebColors.lightBg;
    final text = isDark ? WebColors.darkText : WebColors.lightText;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: text, onPressed: () => Get.back()),
      ),
      body: FutureBuilder<WpPost>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
              child: Text('خطا در بارگذاری', style: TextStyle(color: text)),
            );

          final post = snapshot.data!;
          final dateStr = DateFormat('d MMMM yyyy', 'fa_IR').format(post.date);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // Narrower for reading
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: WebColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'اخبار',
                            style: TextStyle(color: WebColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(dateStr, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      post.title,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.3, color: text),
                    ),
                    const SizedBox(height: 32),
                    // Featured Image (If exists)
                    // Container(height: 400, color: Colors.grey, ...),
                    const SizedBox(height: 32),
                    // Body
                    SelectableText(
                      post.excerpt, // Use 'content' if you have HTML renderer
                      style: TextStyle(fontSize: 18, height: 1.8, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
