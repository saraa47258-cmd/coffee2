import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';
import 'package:ty_cafe/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  OrdersRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('orders');
  }

  @override
  Future<void> createOrder(List<CartItem> items, double totalAmount, {int? tableNumber}) async {
    final collection = _collection;
    if (collection == null) throw Exception('User not authenticated');
    final uid = auth.currentUser?.uid;
    
    final orderData = {
      'total': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
      'userId': uid, // حفظ معرف المستخدم
      if (tableNumber != null) 'tableNumber': tableNumber,
    };
    
    // حفظ الطلب في مكانين:
    // 1. في orders collection العام (للأدمن)
    final orderRef = await firestore.collection('orders').add(orderData);
    
    // 2. في users/{uid}/orders (للمستخدم)
    await collection.doc(orderRef.id).set(orderData);
  }

  @override
  Future<List<OrderModel>> fetchOrders() async {
    final collection = _collection;
    if (collection == null) return [];
    final snapshot = await collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(OrderModel.fromDoc).toList();
  }

  @override
  Future<List<OrderModel>> fetchAllOrders() async {
    // جلب جميع الطلبات من collection العام (للأدمن)
    try {
      final snapshot = await firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final order = OrderModel.fromDoc(doc);
        // التأكد من وجود userId و tableNumber في البيانات
        final data = doc.data();
        final userId = data['userId'] as String?;
        final tableNumber = data['tableNumber'] as int?;
        return OrderModel(
          id: order.id,
          items: order.items,
          total: order.total,
          createdAt: order.createdAt,
          userId: userId,
          tableNumber: tableNumber,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch all orders: $e');
    }
  }
}

