// products_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mashinsazi_akhgar_web/bloc/product/product_bloc.dart';
import 'package:mashinsazi_akhgar_web/theme/theme_cubit.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/product_card_widget.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadAllProducts());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
        context.read<ProductBloc>().add(LoadMoreProducts());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeCubit c) => c.isDark);
    return Scaffold(
      backgroundColor: isDark ? WebColors.darkBg : WebColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? WebColors.darkBg : WebColors.lightBg,
        title: Text('محصولات', style: TextStyle(color: isDark ? WebColors.darkText : WebColors.lightText)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? WebColors.darkText : WebColors.lightText),
          onPressed: () => Get.back(),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.loading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);

                    return Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: state.products.length + (state.status == ProductStatus.loading ? 3 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.products.length) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                              );
                            }
                            final product = state.products[index];
                            return ProductCardWidget(
                              product: product,
                              onTap: () => Get.toNamed('/products/${product.id}'),
                            );
                          },
                        ),
                        if (state.hasReachedMax && state.products.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text('همه محصولات بارگذاری شدند', style: TextStyle(color: isDark ? Colors.grey[400] : WebColors.lightTextSecondary)),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
