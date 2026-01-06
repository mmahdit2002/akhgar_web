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
import 'package:mashinsazi_akhgar_web/ui/widgets/professional_map_widget.dart';
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
    final bgGradient = isDark ? const [Color(0xFF151A2C), Color(0xFF050814), Color(0xFF02030A)] : const [WebColors.lightBg, WebColors.lightBgSoft, WebColors.lightBorder];
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050814) : WebColors.lightBg,
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
    // Use lightHeaderBg in light mode instead of lightBg
    final headerColor = isDark ? const Color(0xFF050814) : WebColors.lightHeaderBg;
    // Force text to be white/light since background is now always dark
    final iconColor = Colors.white70;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.95), // Always dark background
        border: Border(bottom: BorderSide(color: Colors.white10)), // Always subtle border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Stronger shadow for dark bg
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
              // Logo (Keep as is)
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
                      color: Colors.white, // Always white
                    ),
                  ),
                  Text(
                    'Mashinsazi Akhgar',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: Colors.white54, // Always light grey
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Desktop Nav
              if (MediaQuery.of(context).size.width > 900) ...[
                // FORCE isDark = true for links so they render white text
                _headerLink('خانه', () => _scrollTo(0), true),
                _headerLink('محصولات', () => _scrollTo(700), true),
                _headerLink('اخبار', () => _scrollTo(1500), true),
                _headerLink('درباره ما', () => _scrollTo(2200), true),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _scrollTo(3500),
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
                color: iconColor, // Always light
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
      child: HoverTextLink(
        text: label,
        onTap: onTap,
        hoverColor: WebColors.primary, // The color you requested
        baseStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black54,
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
                      'ماشین‌سازی اخگر، راه‌حل‌های نوین برای صنعت مدرن',
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
        color: isDark ? const Color(0xFF050814) : WebColors.lightBgSoft,
        border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : WebColors.lightBorder)),
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
      color: isDark ? const Color(0xFF070B16) : WebColors.lightBgSoft,
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
        color: isDark ? const Color(0xFF0A0E1E) : WebColors.lightBgSoft,
        border: Border.symmetric(horizontal: BorderSide(color: isDark ? Colors.white10 : WebColors.lightBorder)),
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
    final bgGradient = isDark ? const LinearGradient(colors: [Color(0xFF151A2C), Color(0xFF050814)]) : const LinearGradient(colors: [WebColors.lightBgSoft, WebColors.lightBg]);
    final borderColor = isDark ? Colors.white10 : WebColors.lightBorder;
    final textColor = isDark ? Colors.white : WebColors.lightText;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      margin: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              gradient: bgGradient,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Text(
                  'نیاز به مشاوره تخصصی دارید؟',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
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
    // Always use dark gradient
    final footerGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E2329), Color(0xFF15191E)], // Dark Grey/Black for Light Mode too
    );

    // Always use light text colors for footer
    const textColor = Colors.white;
    final secondaryTextColor = Colors.white60;
    const dividerColor = Colors.white10;

    return Container(
      decoration: BoxDecoration(gradient: footerGradient),
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                final footerContent = [
                  // COL 1: Brand Info
                  SizedBox(
                    width: isDesktop ? 300 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: WebColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.precision_manufacturing_rounded, color: WebColors.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'ماشین سازی اخگر',
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'طراحی و ساخت ماشین آلات صنعتی با بالاترین استاندارد کیفیت.\nپیشرو در صنعت رول‌فرمینگ و ماشین‌آلات سنگین.',
                          style: TextStyle(color: secondaryTextColor, height: 1.8, fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            _socialIcon(Icons.telegram, 'https://t.me/akhgar', secondaryTextColor),
                            const SizedBox(width: 16),
                            _socialIcon(Icons.camera_alt, 'https://instagram.com/akhgar', secondaryTextColor),
                            const SizedBox(width: 16),
                            _socialIcon(Icons.video_collection, 'https://aparat.com/akhgar', secondaryTextColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isDesktop) const SizedBox(height: 40),
                  // COL 2: Quick Links
                  SizedBox(
                    width: isDesktop ? 200 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'دسترسی سریع',
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(margin: const EdgeInsets.only(top: 8, bottom: 24), width: 40, height: 2, color: WebColors.primary),
                        _footerLink('محصولات', () => Get.toNamed('/products'), secondaryTextColor),
                        _footerLink('اخبار و مقالات', () => Get.toNamed('/news'), secondaryTextColor),
                        _footerLink('درباره ما', () => _scrollTo(2200), secondaryTextColor),
                        _footerLink('تماس با ما', () => _scrollTo(3500), secondaryTextColor),
                      ],
                    ),
                  ),
                  if (!isDesktop) const SizedBox(height: 40),
                  // COL 3: Contact Info
                  SizedBox(
                    width: isDesktop ? 250 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اطلاعات تماس',
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(margin: const EdgeInsets.only(top: 8, bottom: 24), width: 40, height: 2, color: WebColors.primary),
                        _contactRow(Icons.phone_android, '۰۹۱۲۹۳۷۸۰۱۸ (رضا رضا)', secondaryTextColor),
                        const SizedBox(height: 16),
                        _contactRow(Icons.email_outlined, 'info@akhgar.ir', secondaryTextColor),
                        const SizedBox(height: 16),
                        _contactRow(Icons.location_on_outlined, 'تهران، کهریزک، شهرک صنعتی شمس آباد، بلوار گلستان، گلشن ۱۴، پلاک ۱۵', secondaryTextColor),
                      ],
                    ),
                  ),
                ];

                return Column(
                  children: [
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: footerContent,
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: footerContent,
                      ),
                    const SizedBox(height: 60),
                    // MAP SECTION
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.map_rounded, color: WebColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'مسیریابی کارخانه',
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 350,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            // Use TRUE for isDark to force dark map style or pass custom
                            child: ProfessionalMapWidget(isDark: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    const Divider(color: dividerColor),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('© 2026 Mashinsazi Akhgar.', style: TextStyle(color: Colors.white30, fontSize: 12)),
                        if (isDesktop) Text('Designed with Flutter Web', style: TextStyle(color: Colors.white12, fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: WebColors.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, height: 1.5, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _footerLink(String label, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverTextLink(
        text: label,
        onTap: onTap,
        hoverColor: WebColors.primary, // The color you requested
        icon: const Icon(Icons.arrow_left_rounded), // Pass the icon here
        baseStyle: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url, Color color) {
    return HoverSocialIcon(
      icon: icon,
      url: url,
      color: color,
    );
  }
}

class HoverTextLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle baseStyle;
  final Color hoverColor;
  final Widget? icon; // Optional icon for footer links

  const HoverTextLink({
    super.key,
    required this.text,
    required this.onTap,
    required this.baseStyle,
    required this.hoverColor,
    this.icon,
  });

  @override
  State<HoverTextLink> createState() => _HoverTextLinkState();
}

class _HoverTextLinkState extends State<HoverTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          _isHovered = value;
        });
      },
      // Remove default InkWell splash if you want just text color change,
      // or keep it for touch feedback.
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            // Apply hover color to icon too if present
            IconTheme(
              data: IconThemeData(
                color: _isHovered ? widget.hoverColor : (widget.baseStyle.color ?? Colors.white70),
                size: 16,
              ),
              child: widget.icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            widget.text,
            style: widget.baseStyle.copyWith(
              color: _isHovered ? widget.hoverColor : widget.baseStyle.color,
            ),
          ),
        ],
      ),
    );
  }
}

class HoverSocialIcon extends StatefulWidget {
  final IconData icon;
  final String url;
  final Color color;

  const HoverSocialIcon({super.key, required this.icon, required this.url, required this.color});

  @override
  State<HoverSocialIcon> createState() => _HoverSocialIconState();
}

class _HoverSocialIconState extends State<HoverSocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // Add launchUrl logic here
      onHover: (value) {
        setState(() {
          _isHovered = value;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // Background becomes Primary Color with Opacity on Hover
          color: _isHovered ? WebColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            // Border becomes Primary Color on Hover
            color: _isHovered ? WebColors.primary.withOpacity(0.5) : widget.color,
          ),
        ),
        child: Icon(
          widget.icon,
          // Icon color becomes Primary on Hover
          color: _isHovered ? WebColors.primary : widget.color,
          size: 20,
        ),
      ),
    );
  }
}
