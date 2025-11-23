import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';

abstract class OrdersRepository {
  Future<void> createOrder(List<CartItem> items, double totalAmount, {int? tableNumber});
  Future<List<OrderModel>> fetchOrders();
  Future<List<OrderModel>> fetchAllOrders(); // للأدمن - جلب جميع الطلبات
}

