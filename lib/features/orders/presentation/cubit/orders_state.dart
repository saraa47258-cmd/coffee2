import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';

class OrdersState extends Equatable {
  final List<OrderModel> orders;
  final bool loading;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.loading = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? loading,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [orders, loading, error];
}

