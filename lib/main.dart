import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/ui/pages/home_page.dart';
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
      ],
      child: const MainApp(),
    ),
  );
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
          theme: WebTheme.lightTheme,
          darkTheme: WebTheme.darkTheme,
          themeMode: themeMode,
          locale: const Locale('fa', 'IR'),
          fallbackLocale: const Locale('fa', 'IR'),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const HomePage()),
            GetPage(name: '/products', page: () => const ProductsPage()),
            GetPage(
              name: '/products/:id',
              page: () {
                // Safe parsing of ID from parameters
                final idStr = Get.parameters['id'];
                final id = int.tryParse(idStr ?? '') ?? 0;
                return ProductDetailPage(productId: id);
              },
            ),
            // Add more pages like /about, /contact if you create specific files for them
          ],
        );
      },
    );
  }
}
