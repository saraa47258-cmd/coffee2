import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/admin/data/repositories/admin_products_repository.dart';
import 'package:ty_cafe/features/admin/domain/entities/analytics_data.dart';
import 'package:ty_cafe/features/admin/presentation/cubit/admin_products_cubit.dart';
import 'package:ty_cafe/features/admin/presentation/cubit/admin_products_state.dart';
import 'package:ty_cafe/features/admin/presentation/cubit/analytics_cubit.dart';
import 'package:ty_cafe/features/admin/presentation/cubit/analytics_state.dart';
import 'package:ty_cafe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ty_cafe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ty_cafe/features/auth/presentation/pages/login_page.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import 'package:ty_cafe/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';
import 'package:ty_cafe/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:ty_cafe/features/orders/presentation/cubit/orders_state.dart';

import '../../../../core/theme/app_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository: AuthRepositoryImpl()),
        ),
        BlocProvider(
          create: (_) =>
              OrdersCubit(repository: OrdersRepositoryImpl())..loadAllOrders(),
        ),
        BlocProvider(
          create: (_) =>
              AdminProductsCubit(repository: AdminProductsRepository())
                ..start(),
        ),
        BlocProvider(create: (_) => AnalyticsCubit()),
      ],
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  Future<void> _logout(BuildContext context) async {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.whiteBackground,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(
                  255,
                  238,
                  184,
                  132,
                ).withValues(alpha: 0.03),
                AppColors.whiteBackground,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'لوحة تحكم الأدمن',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          color: AppColors.darkText,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteBackground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.darkText,
                          ),
                          onPressed: () => _logout(context),
                          tooltip: 'تسجيل الخروج',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TabBar(
                      indicatorColor: AppColors.primaryColor,
                      indicatorWeight: 3,
                      labelColor: AppColors.primaryColor,
                      unselectedLabelColor: AppColors.subtleText,
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(text: 'الإحصائيات'),
                        Tab(text: 'الطلبات'),
                        Tab(text: 'المنتجات'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [_AnalyticsTab(), _OrdersTab(), _ProductsTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab();

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  String _selectedPeriod = 'daily'; // daily, weekly, monthly
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataIfNeeded();
    });
  }

  Future<void> _loadDataIfNeeded() async {
    final ordersState = context.read<OrdersCubit>().state;
    final productsState = context.read<AdminProductsCubit>().state;

    // إذا لم تكن هناك بيانات، قم بتحميل البيانات التجريبية تلقائياً
    if (ordersState.orders.isEmpty && !ordersState.loading) {
      await context.read<OrdersCubit>().loadMockOrders();
    }

    if (productsState.products.isEmpty && !productsState.loading) {
      // إضافة المنتجات إلى Firebase بدلاً من التحميل المحلي
      await context.read<AdminProductsCubit>().addMockProductsToFirebase();
    }

    // انتظر قليلاً ثم احسب الإحصائيات
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _calculateAnalytics();
    }
  }

  void _calculateAnalytics() {
    if (_isCalculating) return;

    final ordersState = context.read<OrdersCubit>().state;
    final productsState = context.read<AdminProductsCubit>().state;
    final analyticsState = context.read<AnalyticsCubit>().state;

    // حساب الإحصائيات فقط إذا كانت البيانات متوفرة ولم يتم حسابها بعد
    if (ordersState.orders.isNotEmpty &&
        productsState.products.isNotEmpty &&
        analyticsState.analyticsData == null &&
        !analyticsState.loading) {
      _isCalculating = true;
      try {
        context.read<AnalyticsCubit>().calculateAnalytics(
          orders: ordersState.orders,
          products: productsState.products,
        );
      } finally {
        _isCalculating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, ordersState) {
        return BlocBuilder<AdminProductsCubit, AdminProductsState>(
          builder: (context, productsState) {
            return BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, analyticsState) {
                final hasData =
                    ordersState.orders.isNotEmpty ||
                    productsState.products.isNotEmpty;

                // معالجة الأخطاء أولاً
                if (ordersState.error != null || productsState.error != null) {
                  return _ErrorState(
                    message:
                        ordersState.error ?? productsState.error ?? 'حدث خطأ',
                    onRetry: () {
                      context.read<OrdersCubit>().loadAllOrders();
                      context.read<AdminProductsCubit>().start();
                    },
                  );
                }

                // إذا لم تكن هناك بيانات، قم بتحميل البيانات التجريبية تلقائياً
                if (!hasData &&
                    !ordersState.loading &&
                    !productsState.loading) {
                  // تحميل البيانات التجريبية تلقائياً
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _loadDataIfNeeded();
                    }
                  });
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل البيانات...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.subtleText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // حساب الإحصائيات تلقائياً إذا كانت البيانات متوفرة
                if (hasData &&
                    analyticsState.analyticsData == null &&
                    !analyticsState.loading &&
                    !ordersState.loading &&
                    !productsState.loading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _calculateAnalytics();
                    }
                  });
                }

                // عرض مؤشر التحميل فقط إذا كان هناك تحميل نشط
                if ((analyticsState.loading &&
                        analyticsState.analyticsData == null) ||
                    (ordersState.loading && ordersState.orders.isEmpty) ||
                    (productsState.loading && productsState.products.isEmpty)) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (analyticsState.error != null) {
                  return _ErrorState(
                    message: analyticsState.error!,
                    onRetry: _calculateAnalytics,
                  );
                }

                final analytics = analyticsState.analyticsData;

                // إذا كانت البيانات موجودة ولكن الإحصائيات لم تُحسب بعد
                if (analytics == null && hasData) {
                  // سيتم حسابها تلقائياً في addPostFrameCallback أعلاه
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                // إذا لم تكن هناك إحصائيات (يجب أن يكون hasData = false هنا)
                if (analytics == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<OrdersCubit>().loadAllOrders();
                    await Future.delayed(const Duration(milliseconds: 500));
                    _calculateAnalytics();
                  },
                  color: AppColors.primaryColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // زر تحميل البيانات التجريبية
                        if (!hasData)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'لا توجد بيانات حقيقية',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'قم بتحميل البيانات التجريبية لرؤية الإحصائيات',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: AppColors.subtleText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await context
                                        .read<AdminProductsCubit>()
                                        .addMockProductsToFirebase();
                                    await context
                                        .read<OrdersCubit>()
                                        .loadMockOrders();
                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );
                                    _calculateAnalytics();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'تحميل',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: AppColors.whiteText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // إحصائيات أساسية
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'إجمالي الطلبات',
                                value: analytics.totalOrders.toString(),
                                icon: Icons.shopping_bag_outlined,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'إجمالي الإيرادات',
                                value:
                                    '${analytics.totalRevenue.toStringAsFixed(2)} ر.ع.',
                                icon: Icons.attach_money_rounded,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'متوسط قيمة الطلب',
                                value:
                                    '${analytics.averageOrderValue.toStringAsFixed(2)} ر.ع.',
                                icon: Icons.trending_up,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'عدد العملاء',
                                value: analytics.uniqueCustomers.toString(),
                                icon: Icons.people_outline,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // اختيار الفترة
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.whiteBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.subtleText.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PeriodButton(
                                label: 'يومي',
                                isSelected: _selectedPeriod == 'daily',
                                onTap: () =>
                                    setState(() => _selectedPeriod = 'daily'),
                              ),
                              _PeriodButton(
                                label: 'أسبوعي',
                                isSelected: _selectedPeriod == 'weekly',
                                onTap: () =>
                                    setState(() => _selectedPeriod = 'weekly'),
                              ),
                              _PeriodButton(
                                label: 'شهري',
                                isSelected: _selectedPeriod == 'monthly',
                                onTap: () =>
                                    setState(() => _selectedPeriod = 'monthly'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // رسم بياني للإيرادات
                        _RevenueChart(
                          period: _selectedPeriod,
                          analytics: analytics,
                        ),
                        const SizedBox(height: 24),
                        // رسم بياني للطلبات
                        _OrdersChart(
                          period: _selectedPeriod,
                          analytics: analytics,
                        ),
                        const SizedBox(height: 24),
                        // أفضل المنتجات مبيعاً
                        _TopProductsSection(topProducts: analytics.topProducts),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.whiteText : AppColors.subtleText,
          ),
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final String period;
  final AnalyticsData analytics;

  const _RevenueChart({required this.period, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'الإيرادات',
      icon: Icons.attach_money_rounded,
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    if (period == 'daily') {
      final maxRevenue = analytics.dailyStats
          .map((e) => e.revenue)
          .reduce((a, b) => a > b ? a : b);
      return SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: analytics.dailyStats.map((stat) {
            final height = maxRevenue > 0
                ? (stat.revenue / maxRevenue) * 160
                : 0.0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${stat.date.day}/${stat.date.month}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    color: AppColors.subtleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.revenue.toStringAsFixed(0),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    } else if (period == 'weekly') {
      final maxRevenue = analytics.weeklyStats
          .map((e) => e.revenue)
          .reduce((a, b) => a > b ? a : b);
      return SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: analytics.weeklyStats.map((stat) {
            final height = maxRevenue > 0
                ? (stat.revenue / maxRevenue) * 160
                : 0.0;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.weekLabel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: AppColors.subtleText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.revenue.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      final maxRevenue = analytics.monthlyStats
          .map((e) => e.revenue)
          .reduce((a, b) => a > b ? a : b);
      return SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: analytics.monthlyStats.map((stat) {
            final height = maxRevenue > 0
                ? (stat.revenue / maxRevenue) * 160
                : 0.0;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.monthLabel.split(' ')[0],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      color: AppColors.subtleText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.revenue.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 7,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}

class _OrdersChart extends StatelessWidget {
  final String period;
  final AnalyticsData analytics;

  const _OrdersChart({required this.period, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'عدد الطلبات',
      icon: Icons.shopping_bag_outlined,
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    if (period == 'daily') {
      final maxOrders = analytics.dailyStats
          .map((e) => e.orders)
          .reduce((a, b) => a > b ? a : b);
      return SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: analytics.dailyStats.map((stat) {
            final height = maxOrders > 0
                ? (stat.orders / maxOrders) * 160
                : 0.0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${stat.date.day}/${stat.date.month}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    color: AppColors.subtleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.orders.toString(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    } else if (period == 'weekly') {
      final maxOrders = analytics.weeklyStats
          .map((e) => e.orders)
          .reduce((a, b) => a > b ? a : b);
      return SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: analytics.weeklyStats.map((stat) {
            final height = maxOrders > 0
                ? (stat.orders / maxOrders) * 160
                : 0.0;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.weekLabel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: AppColors.subtleText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.orders.toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      final maxOrders = analytics.monthlyStats
          .map((e) => e.orders)
          .reduce((a, b) => a > b ? a : b);
      return SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: analytics.monthlyStats.map((stat) {
            final height = maxOrders > 0
                ? (stat.orders / maxOrders) * 160
                : 0.0;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.monthLabel.split(' ')[0],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      color: AppColors.subtleText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.orders.toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 7,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartContainer({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  final List<TopProduct> topProducts;

  const _TopProductsSection({required this.topProducts});

  @override
  Widget build(BuildContext context) {
    if (topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'أفضل المنتجات مبيعاً',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الكمية: ${product.quantitySold} | الإيرادات: ${product.totalRevenue.toStringAsFixed(2)} ر.ع.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.subtleText.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state.error != null) {
          return _ErrorState(
            message: state.error!,
            onRetry: () => context.read<OrdersCubit>().loadAllOrders(),
          );
        }

        final orders = state.orders;
        if (orders.isEmpty) {
          return const _EmptyState(
            title: 'لا توجد طلبات حالياً',
            subtitle: 'سيتم عرض الطلبات هنا عند وجودها',
            icon: Icons.shopping_bag_outlined,
          );
        }

        final totalOrders = orders.length;
        final totalRevenue = orders.fold<double>(
          0.0,
          (sum, order) => sum + order.total,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي الطلبات',
                      value: totalOrders.toString(),
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي الإيرادات',
                      value: '${totalRevenue.toStringAsFixed(2)} ر.ع.',
                      icon: Icons.attach_money_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<OrdersCubit>().loadAllOrders(),
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      _AdminOrderCard(order: orders[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  void _openProductForm(BuildContext context, {ProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _ProductFormSheet(product: product, parentContext: context),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final cubit = context.read<AdminProductsCubit>();
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(
              'حذف المنتج',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: Text(
              'هل أنت متأكد من حذف ${product.name}؟',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'حذف',
                  style: TextStyle(color: AppColors.whiteText),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      await cubit.deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminProductsCubit, AdminProductsState>(
      builder: (context, state) {
        if (state.loading && state.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state.error != null) {
          return _ErrorState(
            message: state.error!,
            onRetry: () => context.read<AdminProductsCubit>().start(),
          );
        }

        final products = state.products;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المنتجات',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openProductForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.whiteText,
                    ),
                    label: const Text(
                      'إضافة منتج',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.whiteText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (products.isEmpty)
              const Expanded(
                child: _EmptyState(
                  title: 'لا توجد منتجات',
                  subtitle: 'ابدأ بإضافة المنتج الأول لديك',
                  icon: Icons.coffee_maker_outlined,
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<AdminProductsCubit>().refresh(),
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _AdminProductCard(
                        product: product,
                        onEdit: () =>
                            _openProductForm(context, product: product),
                        onDelete: () => _confirmDelete(context, product),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.subtleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'طلب #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.15),
                      AppColors.primaryColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.userId != null
                      ? 'مستخدم: ${order.userId!.substring(0, 6)}...'
                      : 'غير معروف',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.subtleText.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                order.createdAt.toLocal().toString().split('.').first,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.subtleText.withValues(alpha: 0.8),
                ),
              ),
              if (order.tableNumber != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.table_restaurant,
                  size: 14,
                  color: AppColors.subtleText.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'طاولة ${order.tableNumber}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.subtleText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.subtleText.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.name}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${((double.tryParse(item.product.price) ?? 0.0) * item.quantity).toStringAsFixed(2)} ر.ع.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.subtleText.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.15),
                      AppColors.primaryColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.total.toStringAsFixed(2)} ر.ع.',
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(product.price) ?? 0.0;
    final original = double.tryParse(product.originalPrice) ?? price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
                backgroundImage: product.image.isNotEmpty
                    ? NetworkImage(product.image)
                    : null,
                child: product.image.isEmpty
                    ? const Icon(
                        Icons.local_cafe,
                        color: AppColors.primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.subtleText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.primaryColor,
                tooltip: 'تعديل',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
                tooltip: 'حذف',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${price.toStringAsFixed(2)} ر.ع.',
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              if (product.hasDiscount)
                Text(
                  '${original.toStringAsFixed(2)} ر.ع.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.subtleText,
                  ),
                ),
              const Spacer(),
              if (product.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '-${product.discountPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'لا يوجد وصف لهذا المنتج.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.subtleText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final ProductModel? product;
  final BuildContext? parentContext;

  const _ProductFormSheet({this.product, this.parentContext});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _basePriceCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _tagCtrl;
  late final TextEditingController _tagColorCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _quantityCtrl;

  bool _hasDiscount = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameCtrl = TextEditingController(text: product?.name ?? '');
    _categoryCtrl = TextEditingController(text: product?.category ?? 'All');
    _basePriceCtrl = TextEditingController(
      text: product?.originalPrice ?? product?.price ?? '',
    );
    _imageCtrl = TextEditingController(text: product?.image ?? '');
    _descriptionCtrl = TextEditingController(text: product?.description ?? '');
    _tagCtrl = TextEditingController(text: product?.tag ?? 'موصى به');
    _tagColorCtrl = TextEditingController(text: product?.tagColor ?? '#F47C2B');
    _hasDiscount = product?.hasDiscount ?? false;
    _discountCtrl = TextEditingController(
      text: product != null && product.discountPercent > 0
          ? product.discountPercent.toString()
          : '',
    );
    _quantityCtrl = TextEditingController(
      text: product?.quantity.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _basePriceCtrl.dispose();
    _imageCtrl.dispose();
    _descriptionCtrl.dispose();
    _tagCtrl.dispose();
    _tagColorCtrl.dispose();
    _discountCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Use parentContext if available, otherwise use the current context
    final cubitContext = widget.parentContext ?? context;
    final cubit = cubitContext.read<AdminProductsCubit>();
    final basePrice = double.tryParse(_basePriceCtrl.text.trim()) ?? 0.0;
    final discountPercent = _hasDiscount
        ? double.tryParse(_discountCtrl.text.trim()) ?? 0.0
        : 0.0;
    final finalPrice = _hasDiscount
        ? basePrice * (1 - (discountPercent.clamp(0, 100) / 100))
        : basePrice;
    final quantity = int.tryParse(_quantityCtrl.text.trim()) ?? 0;

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      price: finalPrice.toStringAsFixed(2),
      originalPrice: basePrice.toStringAsFixed(2),
      tag: _tagCtrl.text.trim(),
      tagColor: _tagColorCtrl.text.trim(),
      image: _imageCtrl.text.trim(),
      rating: widget.product?.rating ?? '4.9/5',
      description: _descriptionCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      hasDiscount: _hasDiscount,
      discountPercent: _hasDiscount
          ? discountPercent.clamp(0, 100).toDouble()
          : 0.0,
      quantity: quantity,
    );

    if (widget.product == null) {
      await cubit.addProduct(product);
    } else {
      await cubit.updateProduct(product);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtleText.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج',
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'اسم المنتج',
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(label: 'التصنيف', controller: _categoryCtrl),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'السعر الأساسي',
                controller: _basePriceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => double.tryParse(v ?? '') == null
                    ? 'أدخل رقمًا صحيحًا'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'الكمية المتوفرة',
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = int.tryParse(v ?? '');
                  if (value == null) return 'أدخل رقمًا صحيحًا';
                  if (value < 0) return 'الكمية يجب أن تكون أكبر من أو تساوي 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: _hasDiscount,
                title: const Text(
                  'تفعيل الخصم',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onChanged: (value) {
                  setState(() => _hasDiscount = value);
                },
              ),
              if (_hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTextField(
                    label: 'نسبة الخصم (%)',
                    controller: _discountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final value = double.tryParse(v ?? '');
                      if (value == null) return 'أدخل رقمًا صحيحًا';
                      if (value < 0 || value > 100) {
                        return 'النسبة يجب أن تكون بين 0 و 100';
                      }
                      return null;
                    },
                  ),
                ),
              _buildTextField(label: 'رابط الصورة', controller: _imageCtrl),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'الوصف',
                controller: _descriptionCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'الشارة',
                      controller: _tagCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'لون الشارة',
                      controller: _tagColorCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.product == null ? 'إضافة المنتج' : 'تحديث المنتج',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.whiteText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.whiteText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppColors.primaryColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              color: AppColors.darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.subtleText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
