import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:ty_cafe/features/orders/domain/entities/order_model.dart';
import 'package:ty_cafe/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:ty_cafe/features/orders/presentation/cubit/orders_state.dart';

import '../../../../core/theme/app_colors.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(
        repository: RepositoryProvider.of<OrdersRepositoryImpl>(context),
      )..loadOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteBackground,
        title: const Text(
          'طلباتي',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            color: AppColors.darkText,
          ),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }
          if (state.orders.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات مسجلة',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<OrdersCubit>().loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
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
              Text(
                'طلب #${order.id.substring(0, 6)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                order.createdAt.toLocal().toString().split('.').first,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.subtleText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.take(3).map(
                (item) => Text(
                  '${item.quantity}x ${item.product.name}',
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
          if (order.items.length > 3)
            Text(
              '+${order.items.length - 3} عناصر أخرى',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.subtleText,
              ),
            ),
          const Divider(height: 24),
          Text(
            'الإجمالي: ${order.total.toStringAsFixed(2)} ر.ع.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

