import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';

class AdminProductsState extends Equatable {
  final List<ProductModel> products;
  final bool loading;
  final String? error;

  const AdminProductsState({
    this.products = const [],
    this.loading = false,
    this.error,
  });

  AdminProductsState copyWith({
    List<ProductModel>? products,
    bool? loading,
    String? error,
  }) {
    return AdminProductsState(
      products: products ?? this.products,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [products, loading, error];
}

