import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mashinsazi_akhgar_web/bloc/product/product_bloc.dart';
import 'package:mashinsazi_akhgar_web/models/wp_post.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/feature_card_widget.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/news_card_widget.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/product_card_widget.dart';

import 'package:mashinsazi_akhgar_web/ui/widgets/tech_orbit_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final WpApiService _api = WpApiService(); // For fetching news directly here or use Bloc

  // Animation Controllers for that "Premium" feel
  late AnimationController _orbitController;
  late Future<List<WpPost>> _latestNewsFuture;

  @override
  void initState() {
    super.initState();
    // Load Product data via Bloc
    context.read<ProductBloc>().add(const LoadFeaturedProducts(count: 3));

    // Load News Data (Simple Future for landing preview)
    _latestNewsFuture = _api.fetchLatestPosts(perPage: 3);

    // Orbit Animation for Hero Section
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeCubit c) => c.isDark);

    // Background Colors (Deep Industrial Navy/Black)
    final bgGradient = isDark ? const [Color(0xFF151A2C), Color(0xFF050814), Color(0xFF02030A)] : const [Color(0xFFF0F2F5), Color(0xFFFFFFFF), Color(0xFFE9ECEF)];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050814) : Colors.white,
      body: Stack(
        children: [
          // 1. Global Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.5,
                  colors: bgGradient,
                ),
              ),
            ),
          ),

          // 2. Scrollable Content (With Top Padding for Fixed Header)
          SingleChildScrollView(
            controller: _scrollController,
            // Add padding equal to Header Height (80) to avoid overlap
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              children: [
                const SizedBox(height: 80), // Spacer for the fixed header
                _buildHeroSection(context, isDark),
                _buildFeaturesSection(isDark),
                _buildProductsSection(context, isDark),
                _buildNewsSection(context, isDark), // Added News Section
                _buildAboutSection(context, isDark),
                _buildServicesSection(isDark),
                _buildCtaSection(context, isDark),
                _buildFooter(context, isDark),
              ],
            ),
          ),

          // 3. FIXED HEADER (On Top of everything)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context, isDark),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. HEADER (Fixed & Glassmorphism)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF050814) : Colors.white).withOpacity(0.95),
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, -0.2),
                    colors: [Color(0xFFFFE3B8), Color(0xFFFF8A00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8A00).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MA',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF19110A)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ماشین سازی اخگر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Mashinsazi Akhgar',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Desktop Nav
              if (MediaQuery.of(context).size.width > 900) ...[
                _headerLink('خانه', () => _scrollTo(0), isDark),
                _headerLink('محصولات', () => _scrollTo(700), isDark),
                _headerLink('اخبار', () => _scrollTo(1500), isDark), // Added News Link
                _headerLink('درباره ما', () => _scrollTo(2200), isDark),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _scrollTo(3500), // Contact Offset
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WebColors.primary,
                    foregroundColor: Colors.white,
                    shadowColor: WebColors.primary.withOpacity(0.5),
                    elevation: 8,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('تماس با ما'),
                ),
              ],

              const SizedBox(width: 16),
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                color: isDark ? Colors.white70 : Colors.black54,
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerLink(String label, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. HERO SECTION
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection(BuildContext context, bool isDark) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: const EdgeInsets.only(top: 80, bottom: 80, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              // TEXT SIDE
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: WebColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: WebColors.secondary.withOpacity(0.2)),
                      ),
                      child: const Text(
                        'پیشرو در صنعت ماشین‌سازی',
                        style: TextStyle(color: WebColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'راهکارهای حرفه‌ای\nبرای خطوط تولید مدرن',
                      style: TextStyle(
                        fontSize: isDesktop ? 48 : 36,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: isDark ? Colors.white : const Color(0xFF1A1D1E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'طراحی و ساخت انواع ماشین‌های رول‌تو‌بک، رول‌تو‌رول، گیوتین و خطوط رول‌فرمینگ با دقت میکرونی.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: isDark ? const Color(0xFFA4A9C4) : const Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => Get.toNamed('/products'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('مشاهده محصولات'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () => _scrollTo(3500),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : Colors.black,
                            side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('مشاوره رایگان'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Stats
                    Row(
                      children: [
                        _heroStat('25+', 'سال تجربه', isDark),
                        const SizedBox(width: 40),
                        _heroStat('1000+', 'پروژه موفق', isDark),
                      ],
                    ),
                  ],
                ),
              ),

              // VISUAL SIDE
              if (isDesktop) ...[const SizedBox(width: 60), TechOrbitWidget()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. FEATURES SECTION
  // ---------------------------------------------------------------------------
  Widget _buildFeaturesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF050814) : const Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'چرا ماشین سازی اخگر؟',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.4,
                    children: const [
                      FeatureCardWidget(title: 'مهندسی دقیق', description: 'طراحی با نرم‌افزارهای پیشرفته تحلیل تنش.', icon: Icons.precision_manufacturing),
                      FeatureCardWidget(title: 'تولید سفارشی', description: 'شخصی‌سازی کامل خط تولید.', icon: Icons.tune),
                      FeatureCardWidget(title: 'پشتیبانی مادام‌العمر', description: 'تامین قطعات و خدمات گارانتی.', icon: Icons.verified_user),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. PRODUCTS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildProductsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محصولات برگزیده',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text('تکنولوژی روز دنیا در خطوط تولید شما', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/products'),
                    child: const Row(children: [Text('مشاهده همه'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 16)]),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state.status == ProductStatus.loading) return const CircularProgressIndicator();
                  if (state.products.isEmpty) return const Text('محصولی یافت نشد');

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ProductCardWidget(product: product, onTap: () => Get.toNamed('/products/${product.id}'));
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. NEWS SECTION (New Implementation)
  // ---------------------------------------------------------------------------
  Widget _buildNewsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: isDark ? const Color(0xFF070B16) : Colors.grey[50],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'آخرین اخبار',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/news'),
                    child: const Row(children: [Text('آرشیو اخبار'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 16)]),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              FutureBuilder<List<WpPost>>(
                future: _latestNewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('خبری نیست');

                  final posts = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return NewsCardWidget(post: posts[index], onTap: () => Get.toNamed('/news/${posts[index].id}'));
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. ABOUT SECTION
  // ---------------------------------------------------------------------------
  Widget _buildAboutSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E1E) : Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 60, height: 4, decoration: const BoxDecoration(color: WebColors.primary)),
                    const SizedBox(height: 24),
                    Text(
                      'درباره ماشین سازی اخگر',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 24),
                    Text('گروه صنعتی ماشین سازی اخگر با بیش از دو دهه تجربه...', style: TextStyle(fontSize: 16, height: 1.8, color: isDark ? Colors.white70 : Colors.black87)),
                  ],
                ),
              ),
              if (MediaQuery.of(context).size.width > 900) ...[
                const SizedBox(width: 80),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _statRow('98%', 'رضایت مشتریان', isDark),
                      const SizedBox(height: 32),
                      _statRow('300+', 'ماشین فعال', isDark),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String number, String label, bool isDark) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: WebColors.primary),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. SERVICES & CTA
  // ---------------------------------------------------------------------------
  Widget _buildServicesSection(bool isDark) {
    return Container(); // Placeholder
  }

  Widget _buildCtaSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      margin: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF151A2C), Color(0xFF050814)]),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const Text(
                  'نیاز به مشاوره تخصصی دارید؟',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WebColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  child: const Text('تماس با واحد فروش', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: const Color(0xFF02030A),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ماشین سازی اخگر',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        Text('طراحی و ساخت ماشین آلات صنعتی با بالاترین استاندارد کیفیت.', style: TextStyle(color: Colors.white54, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'دسترسی سریع',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _footerLink('محصولات', () => Get.toNamed('/products')),
                        _footerLink('اخبار', () => Get.toNamed('/news')), // Added News Link
                        _footerLink('درباره ما', () => _scrollTo(2200)),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تماس',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text('info@akhgar.ir', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),
              const Text('© 2025 Mashinsazi Akhgar. All rights reserved.', style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}
