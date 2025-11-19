// lib/features/cart/domain/entities/cart_item.dart
import 'package:ty_cafe/features/home/data/models/product_model.dart';

class CartItem {
  final String id;
  final ProductModel product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      id: id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get unitPrice {
    try {
      // استخراج الرقم من السعر (يدعم تنسيقات مختلفة مثل "15.4 ر.ع." أو "$15.4")
      String priceText = product.price.trim();
      
      // إنشاء string يحتوي فقط على الأرقام والنقطة
      StringBuffer cleaned = StringBuffer();
      bool foundDot = false;
      
      for (int i = 0; i < priceText.length; i++) {
        final char = priceText[i];
        if (char == '.') {
          if (!foundDot) {
            cleaned.write(char);
            foundDot = true;
          }
        } else if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
          // رقم (0-9)
          cleaned.write(char);
        }
      }
      
      final cleanedString = cleaned.toString();
      if (cleanedString.isEmpty) {
        return 0.0;
      }
      
      final parsed = double.tryParse(cleanedString);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    } catch (e) {
      // في حالة أي خطأ، إرجاع 0.0
    }
    return 0.0;
  }

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'product': product.toMap(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: (map['id'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) is int
          ? map['quantity'] as int
          : int.tryParse(map['quantity']?.toString() ?? '') ?? 0,
      product: ProductModel.fromMap(
        Map<String, dynamic>.from(map['product'] ?? {}),
      ),
    );
  }
}
