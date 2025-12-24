import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/web_colors.dart';

class FeatureCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final IconData? icon;

  const FeatureCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic styling based on theme
    final bgColor = isDark ? WebColors.darkBgSoft : WebColors.lightBgSoft;
    final borderColor = isDark ? WebColors.darkBorder : WebColors.lightBorder;
    final textColor = isDark ? WebColors.darkText : WebColors.lightText;
    final subTextColor = isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Section (Only if imageUrl exists)
            if (imageUrl != null)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: isDark ? Colors.grey[900] : Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            // 2. Icon Section (Only if no image, but icon exists)
            else if (icon != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WebColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: WebColors.primary, size: 28),
                ),
              ),

            // 3. Text Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
