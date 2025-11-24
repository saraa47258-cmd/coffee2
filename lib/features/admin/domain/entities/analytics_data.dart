class AnalyticsData {
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int uniqueCustomers;
  final List<DailyStats> dailyStats;
  final List<WeeklyStats> weeklyStats;
  final List<MonthlyStats> monthlyStats;
  final List<TopProduct> topProducts;

  const AnalyticsData({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.uniqueCustomers,
    required this.dailyStats,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.topProducts,
  });

  AnalyticsData copyWith({
    int? totalOrders,
    double? totalRevenue,
    double? averageOrderValue,
    int? uniqueCustomers,
    List<DailyStats>? dailyStats,
    List<WeeklyStats>? weeklyStats,
    List<MonthlyStats>? monthlyStats,
    List<TopProduct>? topProducts,
  }) {
    return AnalyticsData(
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      uniqueCustomers: uniqueCustomers ?? this.uniqueCustomers,
      dailyStats: dailyStats ?? this.dailyStats,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      topProducts: topProducts ?? this.topProducts,
    );
  }
}

class DailyStats {
  final DateTime date;
  final int orders;
  final double revenue;

  const DailyStats({
    required this.date,
    required this.orders,
    required this.revenue,
  });
}

class WeeklyStats {
  final String weekLabel;
  final int orders;
  final double revenue;

  const WeeklyStats({
    required this.weekLabel,
    required this.orders,
    required this.revenue,
  });
}

class MonthlyStats {
  final String monthLabel;
  final int orders;
  final double revenue;

  const MonthlyStats({
    required this.monthLabel,
    required this.orders,
    required this.revenue,
  });
}

class TopProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });
}






