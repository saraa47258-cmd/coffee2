import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';

class MockData {
  // منتجات تجريبية
  static List<ProductModel> getMockProducts() {
    return [
      ProductModel(
        id: 'prod1',
        name: 'قهوة إسبريسو',
        price: '3.50',
        originalPrice: '4.00',
        tag: 'موصى به',
        tagColor: '#F47C2B',
        image: 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04',
        rating: '4.9/5',
        description: 'قهوة إسبريسو قوية ونكهة غنية',
        category: 'قهوة',
        hasDiscount: true,
        discountPercent: 12.5,
        quantity: 50,
      ),
      ProductModel(
        id: 'prod2',
        name: 'كابتشينو',
        price: '4.00',
        originalPrice: '4.50',
        tag: 'جديد',
        tagColor: '#4CAF50',
        image: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d',
        rating: '4.8/5',
        description: 'كابتشينو كريمي مع رغوة الحليب',
        category: 'قهوة',
        hasDiscount: true,
        discountPercent: 11.1,
        quantity: 45,
      ),
      ProductModel(
        id: 'prod3',
        name: 'لاتيه',
        price: '4.50',
        originalPrice: '5.00',
        tag: 'موصى به',
        tagColor: '#F47C2B',
        image: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735',
        rating: '4.9/5',
        description: 'لاتيه ناعم مع حليب مبخر',
        category: 'قهوة',
        hasDiscount: true,
        discountPercent: 10.0,
        quantity: 60,
      ),
      ProductModel(
        id: 'prod4',
        name: 'موكا',
        price: '5.00',
        originalPrice: '5.50',
        tag: 'شائع',
        tagColor: '#9C27B0',
        image: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7',
        rating: '4.7/5',
        description: 'موكا مع شوكولاتة',
        category: 'قهوة',
        hasDiscount: true,
        discountPercent: 9.1,
        quantity: 40,
      ),
      ProductModel(
        id: 'prod5',
        name: 'أمريكانو',
        price: '3.00',
        originalPrice: '3.50',
        tag: '',
        tagColor: '#F47C2B',
        image: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf',
        rating: '4.6/5',
        description: 'أمريكانو خفيف ومنعش',
        category: 'قهوة',
        hasDiscount: true,
        discountPercent: 14.3,
        quantity: 55,
      ),
      ProductModel(
        id: 'prod6',
        name: 'كرواسون',
        price: '2.50',
        originalPrice: '3.00',
        tag: 'جديد',
        tagColor: '#4CAF50',
        image: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a',
        rating: '4.8/5',
        description: 'كرواسون طازج ومقرمش',
        category: 'معجنات',
        hasDiscount: true,
        discountPercent: 16.7,
        quantity: 30,
      ),
      ProductModel(
        id: 'prod7',
        name: 'دونات',
        price: '2.00',
        originalPrice: '2.50',
        tag: 'موصى به',
        tagColor: '#F47C2B',
        image: 'https://images.unsplash.com/photo-1551024506-0bccd828d307',
        rating: '4.9/5',
        description: 'دونات محلى ومغطى بالشوكولاتة',
        category: 'حلويات',
        hasDiscount: true,
        discountPercent: 20.0,
        quantity: 35,
      ),
      ProductModel(
        id: 'prod8',
        name: 'كيك الشوكولاتة',
        price: '4.00',
        originalPrice: '4.50',
        tag: 'شائع',
        tagColor: '#9C27B0',
        image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587',
        rating: '5.0/5',
        description: 'كيك شوكولاتة غني وكريمي',
        category: 'حلويات',
        hasDiscount: true,
        discountPercent: 11.1,
        quantity: 25,
      ),
    ];
  }

  // طلبات تجريبية
  static List<OrderModel> getMockOrders() {
    final products = getMockProducts();
    final now = DateTime.now();
    final orders = <OrderModel>[];

    // طلبات اليوم
    for (int i = 0; i < 8; i++) {
      final items = <CartItem>[];
      final numItems = (i % 3) + 1; // 1-3 منتجات
      double total = 0.0;

      for (int j = 0; j < numItems; j++) {
        final product = products[j % products.length];
        final quantity = (j % 2) + 1; // 1-2 كمية
        final item = CartItem(
          id: 'item_${i}_$j',
          product: product,
          quantity: quantity,
        );
        items.add(item);
        total += item.totalPrice;
      }

      orders.add(OrderModel(
        id: 'order_${now.millisecondsSinceEpoch}_$i',
        items: items,
        total: total,
        createdAt: now.subtract(Duration(hours: i)),
        userId: 'user_${i % 5}', // 5 عملاء مختلفين
      ));
    }

    // طلبات الأمس
    final yesterday = now.subtract(const Duration(days: 1));
    for (int i = 0; i < 12; i++) {
      final items = <CartItem>[];
      final numItems = (i % 3) + 1;
      double total = 0.0;

      for (int j = 0; j < numItems; j++) {
        final product = products[j % products.length];
        final quantity = (j % 2) + 1;
        final item = CartItem(
          id: 'item_yesterday_${i}_$j',
          product: product,
          quantity: quantity,
        );
        items.add(item);
        total += item.totalPrice;
      }

      orders.add(OrderModel(
        id: 'order_yesterday_$i',
        items: items,
        total: total,
        createdAt: yesterday.add(Duration(hours: i % 12)),
        userId: 'user_${i % 5}',
      ));
    }

    // طلبات الأيام السابقة (آخر 7 أيام)
    for (int day = 2; day <= 6; day++) {
      final date = now.subtract(Duration(days: day));
      final numOrders = 5 + (day % 3); // 5-7 طلبات لكل يوم

      for (int i = 0; i < numOrders; i++) {
        final items = <CartItem>[];
        final numItems = (i % 3) + 1;
        double total = 0.0;

        for (int j = 0; j < numItems; j++) {
          final product = products[j % products.length];
          final quantity = (j % 2) + 1;
          final item = CartItem(
            id: 'item_day${day}_${i}_$j',
            product: product,
            quantity: quantity,
          );
          items.add(item);
          total += item.totalPrice;
        }

        orders.add(OrderModel(
          id: 'order_day${day}_$i',
          items: items,
          total: total,
          createdAt: date.add(Duration(hours: i % 12)),
          userId: 'user_${i % 5}',
        ));
      }
    }

    // طلبات الأسابيع السابقة (آخر 4 أسابيع)
    for (int week = 1; week <= 3; week++) {
      final weekStart = now.subtract(Duration(days: 7 * week));
      final numOrders = 15 + (week * 5); // 20-30 طلب لكل أسبوع

      for (int i = 0; i < numOrders; i++) {
        final items = <CartItem>[];
        final numItems = (i % 3) + 1;
        double total = 0.0;

        for (int j = 0; j < numItems; j++) {
          final product = products[j % products.length];
          final quantity = (j % 2) + 1;
          final item = CartItem(
            id: 'item_week${week}_${i}_$j',
            product: product,
            quantity: quantity,
          );
          items.add(item);
          total += item.totalPrice;
        }

        orders.add(OrderModel(
          id: 'order_week${week}_$i',
          items: items,
          total: total,
          createdAt: weekStart.add(Duration(hours: i % 168)), // توزيع على الأسبوع
          userId: 'user_${i % 8}',
        ));
      }
    }

    // طلبات الأشهر السابقة (آخر 6 أشهر)
    for (int month = 1; month <= 5; month++) {
      final monthDate = DateTime(now.year, now.month - month, 1);
      final numOrders = 40 + (month * 10); // 50-90 طلب لكل شهر

      for (int i = 0; i < numOrders; i++) {
        final items = <CartItem>[];
        final numItems = (i % 3) + 1;
        double total = 0.0;

        for (int j = 0; j < numItems; j++) {
          final product = products[j % products.length];
          final quantity = (j % 2) + 1;
          final item = CartItem(
            id: 'item_month${month}_${i}_$j',
            product: product,
            quantity: quantity,
          );
          items.add(item);
          total += item.totalPrice;
        }

        final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
        orders.add(OrderModel(
          id: 'order_month${month}_$i',
          items: items,
          total: total,
          createdAt: monthDate.add(Duration(days: i % daysInMonth)),
          userId: 'user_${i % 10}',
        ));
      }
    }

    return orders;
  }
}






