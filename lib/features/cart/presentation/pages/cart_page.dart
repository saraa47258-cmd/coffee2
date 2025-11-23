import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/cart_item_tile.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            color: AppColors.darkText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.darkText),
            onPressed: () {
              context.read<CartBloc>().add(CartClear());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final items = state.items;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.totalQuantity} items',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.subtleText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المجموع: ${state.totalAmount.toStringAsFixed(1)} ر.ع.',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.lerp(
                            AppColors.primaryColor,
                            Colors.orange,
                            0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                        onPressed: items.isEmpty || state.loading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutPage(
                                      totalAmount: state.totalAmount,
                                      totalQuantity: state.totalQuantity,
                                      items: items,
                                    ),
                                  ),
                                );
                              },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 56,
                                color: AppColors.subtleText,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.subtleText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final it = items[idx];
                            return CartItemTile(item: it);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
