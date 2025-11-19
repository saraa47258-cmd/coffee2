part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class CartStarted extends CartEvent {}

class CartAddItem extends CartEvent {
  final CartItem item;
  const CartAddItem(this.item);

  @override
  List<Object> get props => [item];
}

class CartRemoveItem extends CartEvent {
  final String productId;
  const CartRemoveItem(this.productId);
  @override
  List<Object> get props => [productId];
}

class CartUpdateQuantity extends CartEvent {
  final String productId;
  final int quantity;
  const CartUpdateQuantity(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class CartClear extends CartEvent {}
