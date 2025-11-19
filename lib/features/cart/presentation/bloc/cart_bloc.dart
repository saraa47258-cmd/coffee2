import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart';
import 'package:ty_cafe/features/cart/domain/repositories/cart_repository.dart';
import 'package:ty_cafe/features/orders/domain/repositories/orders_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;
  final OrdersRepository ordersRepository;

  CartBloc({
    required this.repository,
    required this.ordersRepository,
  }) : super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartAddItem>(_onAdd);
    on<CartRemoveItem>(_onRemove);
    on<CartUpdateQuantity>(_onUpdateQuantity);
    on<CartClear>(_onClear);
    on<CartCheckoutRequested>(_onCheckout);
  }

  FutureOr<void> _onStarted(CartStarted e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true));
    final items = await repository.getItems();
    emit(state.copyWith(items: items, loading: false));
  }

  FutureOr<void> _onAdd(CartAddItem e, Emitter<CartState> emit) async {
    await repository.addItem(e.item);
    final items = await repository.getItems();
    emit(state.copyWith(items: items));
  }

  FutureOr<void> _onRemove(CartRemoveItem e, Emitter<CartState> emit) async {
    await repository.removeItem(e.productId);
    final items = await repository.getItems();
    emit(state.copyWith(items: items));
  }

  FutureOr<void> _onUpdateQuantity(
    CartUpdateQuantity e,
    Emitter<CartState> emit,
  ) async {
    final existing = state.items.firstWhere(
      (i) => i.id == e.productId,
      orElse: () => CartItem(
        id: '',
        product: state.items.isNotEmpty
            ? state.items.first.product
            : throw Exception('no product'),
        quantity: 0,
      ),
    );
    if (existing.id != '') {
      if (e.quantity <= 0) {
        await repository.removeItem(e.productId);
      } else {
        final updated = existing.copyWith(quantity: e.quantity);
        await repository.updateItem(updated);
      }
    }
    final items = await repository.getItems();
    emit(state.copyWith(items: items));
  }

  FutureOr<void> _onClear(CartClear e, Emitter<CartState> emit) async {
    await repository.clear();
    emit(state.copyWith(items: []));
  }

  FutureOr<void> _onCheckout(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    if (state.items.isEmpty) return;
    emit(state.copyWith(loading: true));
    try {
      await ordersRepository.createOrder(state.items, state.totalAmount);
      await repository.clear();
      final refreshed = await repository.getItems();
      emit(state.copyWith(items: refreshed, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }
}
