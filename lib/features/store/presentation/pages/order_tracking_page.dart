import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:ty_cafe/features/orders/presentation/cubit/orders_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  @override
  void initState() {
    super.initState();
    // تحميل الطلبات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersCubit>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'تتبع الطلب',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: Responsive.fontSize(context, 22),
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 238, 184, 132).withValues(alpha: 0.03),
              AppColors.whiteBackground,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.orders.isNotEmpty) {
              final orders = state.orders;
              
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppColors.subtleText.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد طلبات',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Responsive.fontSize(context, 18),
                          color: AppColors.subtleText,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(Responsive.spacing(context, 20)),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              );
            }

            return const Center(child: Text('حدث خطأ'));
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final status = _getOrderStatus(order);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 15)),
      padding: EdgeInsets.all(Responsive.spacing(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب #${order.id.substring(0, 8)}',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Responsive.fontSize(context, 12),
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildTimeline(context, status),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع: ${order.total.toStringAsFixed(1)} ر.ع.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                '${order.items.length} منتج',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.fontSize(context, 14),
                  color: AppColors.subtleText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, String currentStatus) {
    final steps = [
      {'status': 'قيد التحضير', 'icon': Icons.restaurant_menu},
      {'status': 'قيد التجهيز', 'icon': Icons.coffee},
      {'status': 'جاهز للاستلام', 'icon': Icons.check_circle_outline},
      {'status': 'تم التسليم', 'icon': Icons.done_all},
    ];

    int currentStep = 0;
    switch (currentStatus) {
      case 'قيد التحضير':
        currentStep = 0;
        break;
      case 'قيد التجهيز':
        currentStep = 1;
        break;
      case 'جاهز للاستلام':
        currentStep = 2;
        break;
      case 'تم التسليم':
        currentStep = 3;
        break;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == steps.length - 1;

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    steps[index]['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted
                        ? AppColors.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                steps[index]['status'] as String,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.fontSize(context, 14),
                  color: isCompleted
                      ? AppColors.darkText
                      : AppColors.subtleText,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getOrderStatus(dynamic order) {
    // يمكنك إضافة منطق لتحديد حالة الطلب من البيانات
    // حالياً نستخدم حالة افتراضية
    try {
      final createdAt = order.createdAt;
      if (createdAt == null) return 'قيد التحضير';
      
      DateTime? orderDate;
      if (createdAt is DateTime) {
        orderDate = createdAt;
      } else {
        // محاولة تحويل Timestamp إلى DateTime
        try {
          orderDate = createdAt.toDate();
        } catch (e) {
          return 'قيد التحضير';
        }
      }
      
      if (orderDate == null) return 'قيد التحضير';
      
      final now = DateTime.now();
      final diff = now.difference(orderDate);
      
      if (diff.inMinutes < 5) return 'قيد التحضير';
      if (diff.inMinutes < 15) return 'قيد التجهيز';
      if (diff.inMinutes < 30) return 'جاهز للاستلام';
      return 'تم التسليم';
    } catch (e) {
      return 'قيد التحضير';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'قيد التحضير':
        return Colors.orange;
      case 'قيد التجهيز':
        return Colors.blue;
      case 'جاهز للاستلام':
        return Colors.green;
      case 'تم التسليم':
        return AppColors.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'قيد التحضير':
        return Icons.restaurant_menu;
      case 'قيد التجهيز':
        return Icons.coffee;
      case 'جاهز للاستلام':
        return Icons.check_circle_outline;
      case 'تم التسليم':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}

