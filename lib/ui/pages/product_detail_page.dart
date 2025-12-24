import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mashinsazi_akhgar_web/models/wp_product.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<WpProduct> _productFuture;
  final WpApiService _api = WpApiService(); // Or get via GetIt/Provider if setup

  @override
  void initState() {
    super.initState();
    // Fetch individual product
    _productFuture = _api.fetchProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeCubit c) => c.isDark);

    return Scaffold(
      // Transparent app bar for a cleaner look
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? WebColors.darkText : WebColors.lightText,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'جزئیات محصول',
          style: TextStyle(
            color: isDark ? WebColors.darkText : WebColors.lightText,
            fontSize: 16,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<WpProduct>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'خطا در بارگذاری محصول',
                    style: TextStyle(
                      color: isDark ? WebColors.darkText : WebColors.lightText,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _productFuture = _api.fetchProduct(widget.productId);
                    }),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('محصول یافت نشد'));
          }

          final product = snapshot.data!;

          // Responsive Layout Builder
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;

              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      // Add top padding to account for extended App Bar
                      padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
                      child: isDesktop ? _buildDesktopView(context, product, isDark) : _buildMobileView(context, product, isDark),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Layouts ---

  Widget _buildDesktopView(BuildContext context, WpProduct product, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Image Side (Expanded)
        Expanded(
          flex: 5,
          child: _buildImageSection(product, isDark),
        ),
        const SizedBox(width: 40),
        // 2. Info Side (Expanded)
        Expanded(
          flex: 4,
          child: _buildInfoSection(context, product, isDark),
        ),
      ],
    );
  }

  Widget _buildMobileView(BuildContext context, WpProduct product, bool isDark) {
    return Column(
      children: [
        _buildImageSection(product, isDark),
        const SizedBox(height: 24),
        _buildInfoSection(context, product, isDark),
      ],
    );
  }

  // --- Components ---

  Widget _buildImageSection(WpProduct product, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 4 / 3, // Standard ratio
        child: product.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? WebColors.darkBgSoft : Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(isDark),
              )
            : _buildPlaceholder(isDark),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WpProduct product, bool isDark) {
    final textColor = isDark ? WebColors.darkText : WebColors.lightText;
    final subTextColor = isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category / Tag (Mockup)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: WebColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'دستگاه صنعتی', // You can map this from WP categories later
            style: TextStyle(
              color: WebColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        SelectableText(
          product.title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: textColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),

        // Excerpt / Description
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? WebColors.darkBgSoft : WebColors.lightBgSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'توضیحات محصول',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                product.excerpt, // Make sure HTML tags are stripped in your Model
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Contact or open a dialog
                  // Get.toNamed('/contact?product=${product.title}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WebColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  shadowColor: WebColors.primary.withOpacity(0.4),
                ),
                child: const Text(
                  'استعلام قیمت و سفارش',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                // Share logic
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
              ),
              child: Icon(Icons.share, color: textColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? WebColors.darkBgSoft : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 64,
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
    );
  }
}
