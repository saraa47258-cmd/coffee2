import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart';
import 'package:ty_cafe/features/cart/domain/repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc({required this.repository}) : super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartAddItem>(_onAdd);
    on<CartRemoveItem>(_onRemove);
    on<CartUpdateQuantity>(_onUpdateQuantity);
    on<CartClear>(_onClear);
  }

  FutureOr<void> _onStarted(CartStarted e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true));
    final items = await repository.getItems();
    emit(state.copyWith(items: items, loading: false));
  }

  FutureOr<void> _onAdd(CartAddItem e, Emitter<CartState> emit) async {
    final exists = state.items.firstWhere(
      (it) => it.id == e.item.id,
      orElse: () => CartItem(id: '', product: e.item.product, quantity: 0),
    );
    if (exists.id == '') {
      await repository.addItem(e.item);
    } else {
      await repository.addItem(e.item);
    }
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
}
