// news_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/wp_post.dart';
import '../../services/wp_api_service.dart';
import '../../theme/theme_cubit.dart';
import '../../theme/web_colors.dart';
import '../widgets/media_carousel.dart'; // Import the new widget

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
    final text = isDark ? WebColors.darkText : WebColors.lightText;
    final secondaryText = isDark ? Colors.grey[400] : WebColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? WebColors.darkBg : WebColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? WebColors.darkBg : WebColors.lightBg,
        surfaceTintColor: Colors.transparent, // Material 3 fix
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: text, onPressed: () => Get.back()),
        title: Text(
          'جزئیات خبر',
          style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: text),
            onPressed: () {
              // Add sharing logic later
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<WpPost>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('خطا در بارگذاری', style: TextStyle(color: text)),
            );
          }

          final post = snapshot.data!;
          final dateStr = DateFormat('d MMMM yyyy', 'fa_IR').format(post.date);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // 1. Multimedia Section (Carousel)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: MediaCarousel(
                        media: post.media,
                        isDark: isDark,
                        height: 450, // Taller for better video experience
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 2. Meta Data & Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: WebColors.secondary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.newspaper, size: 14, color: WebColors.secondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'اخبار',
                                      style: TextStyle(
                                        color: WebColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.calendar_today_outlined, size: 14, color: secondaryText),
                              const SizedBox(width: 6),
                              Text(dateStr, style: TextStyle(color: secondaryText, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SelectableText(
                            post.title,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: text,
                              height: 1.4,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Divider(color: isDark ? Colors.white10 : WebColors.lightBorder, height: 1),
                    const SizedBox(height: 32),

                    // 3. Rich Content (HTML)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Html(
                        data: post.content,
                        style: {
                          "body": Style(
                            fontSize: FontSize(18),
                            lineHeight: LineHeight(1.8),
                            color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF333333),
                            fontFamily: 'IranYekan', // Ensure your font is applied
                            textAlign: TextAlign.justify,
                          ),
                          "p": Style(margin: Margins.only(bottom: 20)),
                          "h1": Style(fontSize: FontSize(28), fontWeight: FontWeight.bold),
                          "h2": Style(fontSize: FontSize(24), fontWeight: FontWeight.bold, margin: Margins.only(top: 30, bottom: 10)),
                          "h3": Style(fontSize: FontSize(20), fontWeight: FontWeight.bold),
                          "img": Style(
                            width: Width(100, Unit.percent),
                            height: Height.auto(),
                            margin: Margins.symmetric(vertical: 24),
                            // borderRadius: BorderRadius.circular(16), // Html widget doesn't support this directly often, handled via CSS usually
                          ),
                          "blockquote": Style(
                            padding: HtmlPaddings.all(16),
                            backgroundColor: isDark ? WebColors.darkBgSoft : WebColors.lightBgSoft,
                            border: Border(right: BorderSide(color: WebColors.secondary, width: 4)),
                            fontStyle: FontStyle.italic,
                            margin: Margins.symmetric(vertical: 20),
                          ),
                          "a": Style(
                            color: WebColors.primary,
                            textDecoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                          ),
                        },
                      ),
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
