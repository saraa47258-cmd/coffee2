import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ty_cafe/features/admin/data/mock_data.dart';
import 'package:ty_cafe/features/admin/data/repositories/admin_products_repository.dart';
import 'package:ty_cafe/features/admin/presentation/cubit/admin_products_state.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  final AdminProductsRepository repository;
  StreamSubscription<List<ProductModel>>? _subscription;

  AdminProductsCubit({required this.repository})
      : super(const AdminProductsState());

  void start() {
    emit(state.copyWith(loading: true, error: null));
    _subscription?.cancel();
    _subscription = repository.watchProducts().listen(
      (products) {
        emit(state.copyWith(products: products, loading: false, error: null));
      },
      onError: (error) {
        emit(state.copyWith(
          loading: false,
          error: error.toString(),
        ));
      },
    );
  }

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(loading: false));
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await repository.addProduct(product);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await repository.updateProduct(product);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await repository.deleteProduct(productId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // تحميل البيانات التجريبية محلياً (للاختبار)
  Future<void> loadMockProducts() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // محاكاة التحميل
      final mockProducts = MockData.getMockProducts();
      emit(state.copyWith(products: mockProducts, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  // إضافة المنتجات التجريبية إلى Firebase
  Future<void> addMockProductsToFirebase() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.addMockProductsToFirebase();
      // البيانات ستُحدّث تلقائياً عبر watchProducts
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

