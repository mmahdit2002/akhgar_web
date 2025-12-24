import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Optional for awesome animations
import 'package:mashinsazi_akhgar_web/bloc/product/product_bloc.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/feature_card.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/product_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<ProductBloc>().add(const LoadFeaturedProducts(count: 3));
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeCubit c) => c.isDark);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Adaptive)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.5,
                  colors: isDark ? [const Color(0xFF151A2C), const Color(0xFF050814)] : [const Color(0xFFFFFFFF), const Color(0xFFF0F2F5)],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildNavBar(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildHero(context, isDark),
                      _buildFeatures(context),
                      _buildProductsSection(context),
                      _buildAboutPreview(context, isDark),
                      _buildFooter(context, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: WebColors.primary,
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildNavBar(BuildContext context, bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: (isDark ? WebColors.darkBg : WebColors.lightBg).withOpacity(0.9),
        border: Border(bottom: BorderSide(color: isDark ? WebColors.darkBorder : WebColors.lightBorder)),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WebColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'MA',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'ماشین سازی اخگر',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? WebColors.darkText : WebColors.lightText),
          ),
          const Spacer(),

          // Desktop Menu (Hidden on mobile)
          if (MediaQuery.of(context).size.width > 800) ...[
            _navItem('خانه', () => Get.toNamed('/')),
            _navItem('محصولات', () => Get.toNamed('/products')),
            _navItem('تماس با ما', () {}), // Implement route
          ],

          const SizedBox(width: 20),
          // Theme Switcher
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            color: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'راهکارهای حرفه‌ای ماشین‌سازی',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: isDark ? WebColors.darkText : WebColors.lightText,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 20),
          Text(
            'طراحی و ساخت انواع ماشین‌های رول‌تو‌بک، رول‌تو‌رول و خطوط تولید پیشرفته',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Get.toNamed('/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('مشاهده محصولات'),
          ).animate().scale(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isMobile ? 1.5 : 1.2, // Adjust ratio for image visibility
              children: const [
                FeatureCard(
                  title: 'طراحی مهندسی',
                  description: 'تحلیل دقیق تنش و طراحی سه‌بعدی پیشرفته',
                  icon: Icons.architecture,
                  // imageUrl: 'https://example.com/engineering.jpg', // Uncomment to test image
                ),
                FeatureCard(
                  title: 'تولید سفارشی',
                  description: 'ساخت ماشین‌آلات متناسب با نیاز خط تولید شما',
                  icon: Icons.settings_suggest,
                ),
                FeatureCard(
                  title: 'پشتیبانی فنی',
                  description: 'خدمات پس از فروش و تعمیرات تخصصی',
                  icon: Icons.support_agent,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text('محصولات برگزیده', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.loading) {
                  return const CircularProgressIndicator();
                }

                if (state.products.isEmpty) {
                  return const Text('محصولی یافت نشد');
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int cols = width > 900 ? 3 : (width > 600 ? 2 : 1);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.75, // Taller for cards
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ProductCardWidget(
                          product: product,
                          onTap: () => Get.toNamed('/products/${product.id}'),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutPreview(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? WebColors.darkBgSoft : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      width: double.infinity,
      child: Column(
        children: [
          const Icon(Icons.business, size: 50, color: WebColors.primary),
          const SizedBox(height: 20),
          const Text('درباره ما', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const SizedBox(
            width: 800,
            child: Text(
              'گروه صنعتی ماشین سازی اخگر با بیش از دو دهه تجربه در طراحی و ساخت ماشین آلات صنعتی...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: () {}, // Add route
            child: const Text('بیشتر بخوانید'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black87;
    return Container(
      color: isDark ? const Color(0xFF02030A) : Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Links Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دسترسی سریع',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 16),
              _footerLink('خانه', () => Get.offAllNamed('/'), textColor),
              _footerLink('محصولات', () => Get.toNamed('/products'), textColor),
              _footerLink('تماس با ما', () {}, textColor),
            ],
          ),
          // Contact Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ارتباط با ما',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 16),
              Text('021-12345678', style: TextStyle(color: textColor)),
              Text('info@akhgar.com', style: TextStyle(color: textColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(text, style: TextStyle(color: color)),
      ),
    );
  }
}
