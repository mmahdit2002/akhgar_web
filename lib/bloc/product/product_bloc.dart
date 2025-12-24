import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mashinsazi_akhgar_web/models/wp_product.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:meta/meta.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final WpApiService api;
  int _page = 1;

  ProductBloc({required this.api}) : super(const ProductState()) {
    on<LoadFeaturedProducts>(_onLoadFeatured);
    on<LoadAllProducts>(_onLoadAll);
    on<LoadMoreProducts>(_onLoadMore);
  }

  Future<void> _onLoadFeatured(LoadFeaturedProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final items = await api.fetchFeaturedProducts(perPage: event.count);
      emit(state.copyWith(status: ProductStatus.success, products: items));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadAll(LoadAllProducts event, Emitter<ProductState> emit) async {
    if (event.isRefresh) _page = 1;
    emit(
      state.copyWith(
        status: ProductStatus.loading,
        products: event.isRefresh ? [] : state.products,
      ),
    );

    try {
      final items = await api.fetchProducts(page: _page);
      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: event.isRefresh ? items : [...state.products, ...items],
          hasReachedMax: items.length < 20,
        ),
      );
      _page++;
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreProducts event, Emitter<ProductState> emit) async {
    if (state.hasReachedMax || state.status == ProductStatus.loading) return;

    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final newItems = await api.fetchProducts(page: _page);
      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: [...state.products, ...newItems],
          hasReachedMax: newItems.length < 20,
        ),
      );
      _page++;
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }
}
