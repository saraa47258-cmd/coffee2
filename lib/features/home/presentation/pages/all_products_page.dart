import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:ty_cafe/features/home/data/datasources/product_data.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import 'package:ty_cafe/features/home/presentation/widgets/product_card.dart';
import '../../../../core/theme/app_colors.dart';

class AllProductsPage extends StatefulWidget {
  final String? initialCategory;
  const AllProductsPage({super.key, this.initialCategory});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Hot Coffee',
    'Cold Coffee',
    'Milk Coffee',
    'Blended',
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortOption = 'none';

  double parsePrice(String price) {
    // استخراج الرقم من السعر (يدعم تنسيقات مختلفة مثل "15.4 ر.ع." أو "$15.4")
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(cleaned);
    return parsed ?? 0.0;
  }

  List<ProductModel> get _filteredProducts {
    final q = _searchQuery.trim().toLowerCase();

    List<ProductModel> result = productList.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    switch (_sortOption) {
      case 'az':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'za':
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'cheap':
        result.sort(
          (a, b) => parsePrice(a.price).compareTo(parsePrice(b.price)),
        );
        break;
      case 'expensive':
        result.sort(
          (a, b) => parsePrice(b.price).compareTo(parsePrice(a.price)),
        );
        break;
      default:
        break;
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null &&
        _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String? localSort = _sortOption;
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: SizedBox(
                      height: 6,
                      width: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(50, 0, 0, 0),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Filter Options",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sort By",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: <Widget>[
                      RadioListTile<String>(
                        value: 'none',
                        groupValue: localSort,
                        onChanged: (String? v) {
                          setStateSheet(() {
                            localSort = v;
                          });
                        },
                        title: const Text(
                          'Default',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),

                      RadioListTile<String>(
                        value: 'az',
                        groupValue: localSort,
                        onChanged: (String? v) {
                          setStateSheet(() {
                            localSort = v;
                          });
                        },
                        title: const Text(
                          'A → Z',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),

                      RadioListTile<String>(
                        value: 'za',
                        groupValue: localSort,
                        onChanged: (String? v) {
                          setStateSheet(() {
                            localSort = v;
                          });
                        },
                        title: const Text(
                          'Z → A',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),

                      RadioListTile<String>(
                        value: 'cheap',
                        groupValue: localSort,
                        onChanged: (String? v) {
                          setStateSheet(() {
                            localSort = v;
                          });
                        },
                        title: const Text(
                          'Lowest Price',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),

                      RadioListTile<String>(
                        value: 'expensive',
                        groupValue: localSort,
                        onChanged: (String? v) {
                          setStateSheet(() {
                            localSort = v;
                          });
                        },
                        title: const Text(
                          'Highest Price',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.whiteBackground,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.lerp(
                              AppColors.primaryColor,
                              Colors.orange,
                              0.6,
                            )!,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _sortOption = localSort ?? 'none';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Apply Filter",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.darkText),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          "All Products",
          style: TextStyle(
            fontFamily: "PlayfairDisplay",
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: 'Search products',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.subtleText,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.subtleText,
                ),
                filled: true,
                fillColor: AppColors.whiteBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.subtleText,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _openFilterSheet,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.tune, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final item = _categories[index];
          final isSelected = item == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = item;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color.lerp(AppColors.primaryColor, Colors.orange, 0.6)!
                    : AppColors.whiteBackground,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.whiteText
                        : AppColors.darkText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search_off, size: 56, color: AppColors.subtleText),
            SizedBox(height: 12),
            Text(
              'No products found',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.subtleText,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: products.length,
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, favState) {
            final isFav = favState.favoriteIds.contains(product.id);
            return ProductCard(product: product, isFavorite: isFav);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildCategoryList(),
                const SizedBox(height: 16),
                Expanded(child: _buildProductGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
