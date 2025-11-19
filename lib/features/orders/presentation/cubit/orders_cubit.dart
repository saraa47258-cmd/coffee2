import 'package:bloc/bloc.dart';
import 'package:ty_cafe/features/orders/domain/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;

  OrdersCubit({required this.repository}) : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final orders = await repository.fetchOrders();
      emit(state.copyWith(orders: orders, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadAllOrders() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final orders = await repository.fetchAllOrders();
      emit(state.copyWith(orders: orders, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}

