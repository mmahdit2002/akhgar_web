import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mashinsazi_akhgar_web/models/wp_product.dart';
import 'package:mashinsazi_akhgar_web/models/wp_review.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/app_video_player.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<WpProduct> _productFuture;
  final WpApiService _api = WpApiService();

  // Carousel
  final ValueNotifier<int> _carouselIndex = ValueNotifier(0);
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _productFuture = _api.fetchProduct(widget.productId);
  }

  @override
  void dispose() {
    _carouselIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeCubit c) => c.isDark);

    return Scaffold(
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
              child: Text('خطا در بارگذاری', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            );
          }
          if (!snapshot.hasData) return const Center(child: Text('محصول یافت نشد'));

          final product = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
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

  Widget _buildDesktopView(BuildContext context, WpProduct product, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildImageSection(product, isDark)),
        const SizedBox(width: 40),
        Expanded(flex: 4, child: _buildInfoSection(context, product, isDark)),
      ],
    );
  }

  Widget _buildMobileView(BuildContext context, WpProduct product, bool isDark) {
    return Column(
      children: [
        _buildImageSection(product, isDark),
        const SizedBox(height: 32),
        _buildInfoSection(context, product, isDark),
      ],
    );
  }

  // === IMAGE SECTION (Centered Thumbnails) ===
  Widget _buildImageSection(WpProduct product, bool isDark) {
    if (product.media.isEmpty) return _buildPlaceholder(isDark);

    return Column(
      children: [
        // 1. Main Big Image
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: isDark ? WebColors.darkBgSoft : Colors.grey[100],
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: product.media.length,
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) => _carouselIndex.value = index,
              ),
              itemBuilder: (context, index, realIndex) {
                final media = product.media[index];
                if (media.type == 'video') {
                  return AppVideoPlayer(videoUrl: media.url, autoPlay: false);
                }
                return CachedNetworkImage(
                  imageUrl: media.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                );
              },
            ),
          ),
        ),

        // 2. Centered Thumbnails
        if (product.media.length > 1) ...[
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _carouselIndex,
            builder: (context, activeIndex, child) {
              return Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(product.media.length, (index) {
                      final media = product.media[index];
                      final isActive = index == activeIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => _carouselController.animateToPage(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: isActive ? WebColors.primary : Colors.transparent, width: 2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: media.type == 'video'
                                  ? Container(
                                      color: Colors.black,
                                      child: const Center(child: Icon(Icons.play_circle, color: Colors.white, size: 30)),
                                    )
                                  : CachedNetworkImage(imageUrl: media.url, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(color: isDark ? WebColors.darkBgSoft : Colors.grey[200], borderRadius: BorderRadius.circular(24)),
      child: Icon(Icons.image_not_supported_outlined, size: 60, color: isDark ? Colors.white24 : Colors.black26),
    );
  }

  // === INFO SECTION (Fixed Tabs) ===
  Widget _buildInfoSection(BuildContext context, WpProduct product, bool isDark) {
    final textColor = isDark ? WebColors.darkText : WebColors.lightText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: WebColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(
            'دستگاه صنعتی',
            style: TextStyle(color: WebColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        SelectableText(
          product.title,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, height: 1.2),
        ),
        const SizedBox(height: 16),
        if (product.excerpt.isNotEmpty)
          Text(
            product.excerpt,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),

        const SizedBox(height: 32),

        // Beautiful Tab Section
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // 1. Custom Tab Bar Container
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? WebColors.darkBgSoft.withOpacity(0.5) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  // 1. ADD THIS LINE: Matches your Container's border radius
                  splashBorderRadius: BorderRadius.circular(22),
                  indicator: BoxDecoration(
                    color: WebColors.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: WebColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'توضیحات'),
                    Tab(text: 'مشخصات'),
                    Tab(text: 'نظرات'),
                  ],
                ),
              ),

              // 2. Content Box
              Container(
                height: 400,
                margin: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  color: isDark ? WebColors.darkBgSoft : WebColors.lightBgSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? WebColors.darkBorder : Colors.grey[200]!),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: TabBarView(
                    children: [
                      // Tab 1: Full Description
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: SelectableText(
                          product.description.isEmpty ? 'توضیحات تکمیلی ثبت نشده است.' : product.description,
                          style: TextStyle(fontSize: 15, height: 1.8, color: textColor),
                        ),
                      ),
                      // Tab 2: Additional Info
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildAdditionalInfoTable(product, isDark, textColor),
                      ),
                      // Tab 3: Reviews
                      _buildReviewsTab(product.id, isDark, textColor),
                    ],
                  ),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: WebColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  shadowColor: WebColors.primary.withOpacity(0.4),
                ),
                child: const Text('استعلام قیمت و سفارش', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                if (product.link != null) {
                  Clipboard.setData(ClipboardData(text: product.link!));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لینک کپی شد')));
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Icon(Icons.share, color: textColor),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: Specs Table
  Widget _buildAdditionalInfoTable(WpProduct product, bool isDark, Color textColor) {
    final Map<String, String> specs = {};

    if (product.categories.isNotEmpty) specs['دسته بندی'] = product.categories.map((e) => e.name).join('، ');
    if (product.brands.isNotEmpty) specs['برند'] = product.brands.map((e) => e.name).join('، ');

    for (var attr in product.attributes) {
      specs[attr.name] = attr.options.join('، ');
    }

    specs['وضعیت'] = product.status ?? '-';
    specs['نوع دستگاه'] = product.type ?? '-';
    // if (product.slug != null) specs['شناسه'] = product.slug!;

    var index = 0;
    return Column(
      children: specs.entries.map((entry) {
        final isEven = index % 2 == 0;
        index++;
        return Container(
          decoration: BoxDecoration(color: isEven ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  entry.key,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper: Reviews
  Widget _buildReviewsTab(int productId, bool isDark, Color textColor) {
    return FutureBuilder<List<WpReview>>(
      future: _api.fetchReviews(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('هنوز نظری ثبت نشده است', style: TextStyle(color: textColor)),
              ],
            ),
          );
        }

        final reviews = snapshot.data!;
        return ListView.separated(
          itemCount: reviews.length,
          padding: const EdgeInsets.all(24),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? WebColors.darkBg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: WebColors.primary.withOpacity(0.1),
                    child: Text(review.author.isNotEmpty ? review.author[0] : '?', style: TextStyle(color: WebColors.primary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.author,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text('${review.date.year}/${review.date.month}/${review.date.day}', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review.content, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
