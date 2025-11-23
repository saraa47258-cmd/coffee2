import 'package:bloc/bloc.dart';
import 'package:ty_cafe/features/admin/domain/entities/analytics_data.dart';
import 'package:ty_cafe/features/admin/presentation/cubit/analytics_state.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit() : super(const AnalyticsState());

  void calculateAnalytics({
    required List<OrderModel> orders,
    required List<ProductModel> products,
  }) {
    emit(state.copyWith(loading: true, error: null));

    try {
      // حساب الإحصائيات الأساسية
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0.0,
        (sum, order) => sum + order.total,
      );
      final averageOrderValue =
          totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
      final uniqueCustomers = orders
          .where((order) => order.userId != null)
          .map((order) => order.userId!)
          .toSet()
          .length;

      // حساب الإحصائيات اليومية (آخر 7 أيام)
      final now = DateTime.now();
      final dailyStats = <DailyStats>[];
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: i));
        final nextDate = date.add(const Duration(days: 1));
        final dayOrders = orders.where((order) {
          return order.createdAt.isAfter(date) &&
              order.createdAt.isBefore(nextDate);
        }).toList();
        dailyStats.add(DailyStats(
          date: date,
          orders: dayOrders.length,
          revenue: dayOrders.fold<double>(
            0.0,
            (sum, order) => sum + order.total,
          ),
        ));
      }

      // حساب الإحصائيات الأسبوعية (آخر 4 أسابيع)
      final weeklyStats = <WeeklyStats>[];
      for (int i = 3; i >= 0; i--) {
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: (i * 7) + now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekOrders = orders.where((order) {
          return order.createdAt.isAfter(weekStart) &&
              order.createdAt.isBefore(weekEnd);
        }).toList();
        weeklyStats.add(WeeklyStats(
          weekLabel: 'أسبوع ${4 - i}',
          orders: weekOrders.length,
          revenue: weekOrders.fold<double>(
            0.0,
            (sum, order) => sum + order.total,
          ),
        ));
      }

      // حساب الإحصائيات الشهرية (آخر 6 أشهر)
      final monthlyStats = <MonthlyStats>[];
      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);
        final monthOrders = orders.where((order) {
          return order.createdAt.isAfter(monthDate) &&
              order.createdAt.isBefore(nextMonth);
        }).toList();
        final monthNames = [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر'
        ];
        monthlyStats.add(MonthlyStats(
          monthLabel: '${monthNames[monthDate.month - 1]} ${monthDate.year}',
          orders: monthOrders.length,
          revenue: monthOrders.fold<double>(
            0.0,
            (sum, order) => sum + order.total,
          ),
        ));
      }

      // حساب أفضل المنتجات مبيعاً
      final productSales = <String, Map<String, dynamic>>{};
      for (final order in orders) {
        for (final item in order.items) {
          final productId = item.product.id;
          if (productSales.containsKey(productId)) {
            productSales[productId]!['quantity'] += item.quantity;
            productSales[productId]!['revenue'] +=
                (double.tryParse(item.product.price) ?? 0.0) * item.quantity;
          } else {
            productSales[productId] = {
              'name': item.product.name,
              'quantity': item.quantity,
              'revenue': (double.tryParse(item.product.price) ?? 0.0) *
                  item.quantity,
            };
          }
        }
      }

      final topProducts = productSales.entries
          .map((entry) => TopProduct(
                productId: entry.key,
                productName: entry.value['name'] as String,
                quantitySold: entry.value['quantity'] as int,
                totalRevenue: entry.value['revenue'] as double,
              ))
          .toList()
        ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

      final analyticsData = AnalyticsData(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        uniqueCustomers: uniqueCustomers,
        dailyStats: dailyStats,
        weeklyStats: weeklyStats,
        monthlyStats: monthlyStats,
        topProducts: topProducts.take(10).toList(),
      );

      emit(state.copyWith(
        loading: false,
        analyticsData: analyticsData,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}

