import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String? userId; // معرف المستخدم (للأدمن)

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    this.userId,
  });

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final itemsData = (data['items'] as List<dynamic>? ?? [])
        .map((entry) => CartItem.fromMap(Map<String, dynamic>.from(entry)))
        .toList();
    final timestamp = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    }
    return OrderModel(
      id: doc.id,
      items: itemsData,
      total: (data['total'] ?? 0) is num
          ? (data['total'] as num).toDouble()
          : double.tryParse(data['total']?.toString() ?? '') ?? 0.0,
      createdAt: createdAt,
      userId: data['userId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((item) => item.toMap()).toList(),
      if (userId != null) 'userId': userId,
    };
  }
}

