import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/cart/domain/entities/cart_item.dart'
    as CartEntity;
import 'package:ty_cafe/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  int _selectedSize = 1;
  int _selectedSugar = 0;
  int _selectedIce = 0;
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final priceText = product.price;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
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
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 340,
                  toolbarHeight: 60,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: CircleAvatar(
                      backgroundColor: AppColors.whiteBackground,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.darkText,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CircleAvatar(
                        backgroundColor: AppColors.whiteBackground,
                        child: BlocBuilder<FavoriteBloc, FavoriteState>(
                          builder: (context, favState) {
                            final isFav = favState.favoriteIds.contains(
                              product.id,
                            );
                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : AppColors.darkText,
                              ),
                              onPressed: () {
                                context.read<FavoriteBloc>().add(
                                  FavoriteToggleRequested(product.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(milliseconds: 800),
                                    content: Text(
                                      isFav
                                          ? '${product.name} removed from favorites'
                                          : '${product.name} added to favorites',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 20,
                        right: 20,
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'product_image_${product.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: Image.asset(
                              product.image,
                              width: 260,
                              height: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset(
                                'assets/images/coffe.webp',
                                width: 260,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.whiteBackground,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (_quantity > 1) {
                                        setState(() => _quantity--);
                                      }
                                    },
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () =>
                                        setState(() => _quantity++),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.rating,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.subtleText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildOptionSection(
                          'Size',
                          ['Small', 'Medium', 'Large'],
                          _selectedSize,
                          (i) => setState(() => _selectedSize = i),
                        ),
                        const SizedBox(height: 10),
                        _buildOptionSection(
                          'Sugar',
                          ['Normal', 'Less', 'No'],
                          _selectedSugar,
                          (i) => setState(() => _selectedSugar = i),
                        ),
                        const SizedBox(height: 10),
                        _buildOptionSection(
                          'Ice',
                          ['Normal', 'Less', 'No'],
                          _selectedIce,
                          (i) => setState(() => _selectedIce = i),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDescription(product.description),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            priceText,
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          if (product.originalPrice.isNotEmpty)
                            Text(
                              product.originalPrice,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.subtleText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.lerp(
                            AppColors.primaryColor,
                            Colors.orange,
                            0.6,
                          )!,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26.0,
                            vertical: 2.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          final cartItem = CartEntity.CartItem(
                            id: product.id,
                            product: product,
                            quantity: _quantity,
                          );

                          context.read<CartBloc>().add(CartAddItem(cartItem));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 900),
                              content: Text(
                                'Added $_quantity x ${product.name} to cart',
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                              backgroundColor: AppColors.primaryColor
                                  .withValues(alpha: 0.9),
                            ),
                          );
                        },
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSection(
    String title,
    List<String> options,
    int selectedIndex,
    Function(int) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: List.generate(options.length, (i) {
            final selected = i == selectedIndex;
            return SizedBox(
              height: 30,
              child: ChoiceChip(
                label: Text(
                  options[i],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: selected ? AppColors.whiteText : AppColors.darkText,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                selected: selected,
                onSelected: (_) => onSelected(i),
                backgroundColor: AppColors.whiteBackground,
                selectedColor: Color.lerp(
                  AppColors.primaryColor,
                  Colors.orange,
                  0.6,
                )!,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDescription(String desc) {
    final text = desc.isNotEmpty
        ? desc
        : 'Indulge in the smooth elegance of Velvet Cappuccino, where rich espresso meets perfectly steamed milk to create a luxurious harmony of flavor.';
    final preview = text.length > 120 ? '${text.substring(0, 120)}...' : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _descExpanded ? text : preview,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.subtleText,
            height: 1.4,
          ),
        ),
        if (text.length > 120)
          TextButton(
            onPressed: () => setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? 'See less' : 'See more',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
