import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/wp_post.dart';
import '../../theme/web_colors.dart';

class NewsCardWidget extends StatelessWidget {
  final WpPost post;
  final VoidCallback onTap;

  const NewsCardWidget({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format Date (Ensure you called initializeDateFormatting in main)
    final dateStr = DateFormat('d MMMM yyyy', 'fa_IR').format(post.date);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? WebColors.darkBgSoft : WebColors.lightBgSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? WebColors.darkBorder : WebColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image (Optional: WP posts might not always have images, handle gracefully)
              // Assuming your WpPost model has an 'imageUrl' or similar logic
              // If not, use a pattern placeholder
              AspectRatio(
                aspectRatio: 1.6,
                child: Container(
                  color: isDark ? const Color(0xFF151A2C) : const Color(0xFFEEEEEE),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Replace with actual image if available in WpPost
                      // CachedNetworkImage(imageUrl: post.imageUrl ...),
                      Center(
                        child: Icon(
                          Icons.article_outlined,
                          size: 40,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      // Date Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: WebColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? WebColors.darkText : WebColors.lightText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          post.excerpt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'ادامه مطلب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WebColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_back_rounded, size: 14, color: WebColors.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
