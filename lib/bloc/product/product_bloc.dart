import 'package:bloc/bloc.dart';
import 'package:mashinsazi_akhgar_web/models/wp_product.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final WpApiService api;

  ProductBloc({required this.api}) : super(const ProductState()) {
    on<LoadFeaturedProducts>(_onLoadFeatured);
    on<LoadAllProducts>(_onLoadAll);
  }

  Future<void> _onLoadFeatured(
    LoadFeaturedProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final items = await api.fetchFeaturedProducts(perPage: event.count);
      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadAll(
    LoadAllProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final items = await api.fetchAllProducts(perPage: event.count);
      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
