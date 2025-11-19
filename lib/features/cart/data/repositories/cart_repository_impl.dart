import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Map<String, CartItem> _storage = {};

  @override
  Future<void> addItem(CartItem item) async {
    final exists = _storage[item.id];
    if (exists != null) {
      _storage[item.id] = exists.copyWith(
        quantity: exists.quantity + item.quantity,
      );
    } else {
      _storage[item.id] = item;
    }
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<void> removeItem(String productId) async {
    _storage.remove(productId);
  }

  @override
  Future<void> updateItem(CartItem item) async {
    if (_storage.containsKey(item.id)) {
      _storage[item.id] = item;
    }
  }

  @override
  Future<List<CartItem>> getItems() async {
    return _storage.values.toList(growable: false);
  }
}
