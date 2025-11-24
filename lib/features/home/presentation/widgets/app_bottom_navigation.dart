import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _cartIconWithBadge(BuildContext context, {required bool active}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        Positioned(
          right: -10,
          top: -6,
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final count = state.totalQuantity;
              if (count <= 0) return const SizedBox.shrink();
              final display = count > 99 ? '99+' : count.toString();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.subtleText.withValues(alpha: 0.7),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.whiteBackground,
        elevation: 10,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'المتجر',
          ),
          BottomNavigationBarItem(
            icon: _cartIconWithBadge(context, active: false),
            activeIcon: _cartIconWithBadge(context, active: true),
            label: 'Cart',
          ),

          BottomNavigationBarItem(
            icon: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favState) {
                final hasFav = favState.favoriteIds.isNotEmpty;
                return _buildFavoriteIcon(
                  context,
                  active: false,
                  hasFavorites: hasFav,
                );
              },
            ),
            activeIcon: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favState) {
                return _buildFavoriteIcon(
                  context,
                  active: true,
                  hasFavorites: favState.favoriteIds.isNotEmpty,
                );
              },
            ),
            label: 'Favorite',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon(
    BuildContext context, {
    required bool active,
    required bool hasFavorites,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.favorite : Icons.favorite_border),
        if (hasFavorites)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
