part of 'product_bloc.dart';

@immutable
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeaturedProducts extends ProductEvent {
  final int count;
  const LoadFeaturedProducts({this.count = 3});
}

class LoadAllProducts extends ProductEvent {
  final int count;
  const LoadAllProducts({this.count = 20});
}
