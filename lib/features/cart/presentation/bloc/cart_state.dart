part of 'cart_bloc.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final bool loading;
  const CartState({this.items = const [], this.loading = false});

  double get totalAmount => items.fold(0.0, (s, i) => s + i.totalPrice);
  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);

  CartState copyWith({List<CartItem>? items, bool? loading}) {
    return CartState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [items, loading];
}
