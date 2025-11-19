import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getItems();
  Future<void> addItem(CartItem item);
  Future<void> updateItem(CartItem item);
  Future<void> removeItem(String productId);
  Future<void> clear();
}
