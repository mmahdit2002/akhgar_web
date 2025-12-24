import 'package:flutter/gestures.dart'; // Required for PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mashinsazi_akhgar_web/bloc/post/post_bloc.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/ui/pages/home_page.dart';
import 'package:mashinsazi_akhgar_web/ui/pages/news_detail_page.dart';
import 'package:mashinsazi_akhgar_web/ui/pages/news_page.dart';
import 'package:mashinsazi_akhgar_web/ui/pages/product_detail_page.dart';
import 'package:mashinsazi_akhgar_web/ui/pages/products_page.dart';

import 'bloc/product/product_bloc.dart';
import 'services/wp_api_service.dart';
import 'theme/web_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fa_IR', null);

  final apiService = WpApiService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ProductBloc(api: apiService)),
        BlocProvider(create: (_) => PostBloc(api: apiService)),
      ],
      child: const MainApp(),
    ),
  );
}

// 1. Define Custom Scroll Behavior for Desktop Dragging
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // 👈 Enables mouse dragging
    PointerDeviceKind.trackpad,
  };
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return GetMaterialApp(
          title: 'ماشین سازی اخگر | Mashinsazi Akhgar',
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(), // 👈 Apply globally
          theme: WebTheme.lightTheme,
          darkTheme: WebTheme.darkTheme,
          themeMode: themeMode,
          locale: const Locale('fa', 'IR'),
          fallbackLocale: const Locale('fa', 'IR'),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const HomePage()),
            GetPage(name: '/products', page: () => const ProductsPage()),
            GetPage(name: '/news', page: () => const NewsPage()),
            GetPage(
              name: '/products/:id',
              page: () {
                final idStr = Get.parameters['id'];
                final id = int.tryParse(idStr ?? '') ?? 0;
                return ProductDetailPage(productId: id);
              },
            ),
            GetPage(
              name: '/news/:id',
              page: () {
                final idStr = Get.parameters['id'];
                final id = int.tryParse(idStr ?? '') ?? 0;
                return NewsDetailPage(postId: id);
              },
            ),
          ],
        );
      },
    );
  }
}
