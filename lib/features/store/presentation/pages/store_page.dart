import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:ty_cafe/features/home/data/datasources/product_data.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import 'package:ty_cafe/features/home/presentation/widgets/product_card.dart';
import 'package:ty_cafe/features/store/presentation/pages/product_comparison_page.dart';
import 'package:ty_cafe/features/store/presentation/pages/order_tracking_page.dart';
import 'package:ty_cafe/features/store/presentation/pages/branches_map_page.dart';
import 'package:ty_cafe/features/store/presentation/pages/table_booking_page.dart';
import 'package:ty_cafe/features/store/presentation/pages/pre_order_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    "الكل",
    "أدوات القهوة",
    "أدوات الإسبريسو",
    "البن",
    "قهوة ساخنة",
    "قهوة باردة",
    "قهوة بالحليب",
    "مشروبات مخفوقة",
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final AnimationController _controller;
  late final Animation<double> _appBarAnim;
  late final Animation<double> _searchAnim;
  late final Animation<double> _categoriesAnim;
  late final Animation<double> _productsAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _appBarAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
    );
    _searchAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.30, curve: Curves.easeOut),
    );
    _categoriesAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.50, curve: Curves.easeOut),
    );
    _productsAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final selectedCategory = _categories[_selectedCategoryIndex];
    final categoryMap = {
      "الكل": "All",
      "أدوات القهوة": "أدوات القهوة",
      "أدوات الإسبريسو": "أدوات الإسبريسو",
      "البن": "البن",
      "قهوة ساخنة": "Hot Coffee",
      "قهوة باردة": "Cold Coffee",
      "قهوة بالحليب": "Milk Coffee",
      "مشروبات مخفوقة": "Blended",
    };
    
    final targetCategory = categoryMap[selectedCategory] ?? "All";
    
    return productList.where((p) {
      final matchesCategory = targetCategory == 'All' || p.category == targetCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget _buildEnterAnimation({
    required Widget child,
    required Animation<double> anim,
    double startOffset = 20,
  }) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, startOffset / 100),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildEnterAnimation(
                    child: _buildAppBar(context),
                    anim: _appBarAnim,
                  ),
                  SizedBox(height: Responsive.spacing(context, 15)),
                  _buildEnterAnimation(
                    child: _buildSearchBar(context),
                    anim: _searchAnim,
                    startOffset: 10,
                  ),
                  SizedBox(height: Responsive.spacing(context, 15)),
                  _buildEnterAnimation(
                    child: _buildQuickActions(context),
                    anim: _searchAnim,
                    startOffset: 10,
                  ),
                  SizedBox(height: Responsive.spacing(context, 20)),
                  _buildEnterAnimation(
                    child: _buildCategories(context),
                    anim: _categoriesAnim,
                  ),
                  SizedBox(height: Responsive.spacing(context, 20)),
                  Expanded(
                    child: _buildProductGrid(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "المتجر",
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: Responsive.fontSize(context, 28),
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          Container(
            padding: EdgeInsets.all(Responsive.spacing(context, 8)),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.store_outlined,
              color: AppColors.primaryColor,
              size: Responsive.iconSize(context, 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'مقارنة',
        'subtitle': 'الأسعار',
        'icon': Icons.compare_arrows,
        'color': Colors.blue,
        'page': const ProductComparisonPage(),
      },
      {
        'title': 'تتبع',
        'subtitle': 'الطلب',
        'icon': Icons.track_changes,
        'color': Colors.green,
        'page': const OrderTrackingPage(),
      },
      {
        'title': 'فروعنا',
        'subtitle': '',
        'icon': Icons.location_on,
        'color': Colors.red,
        'page': const BranchesMapPage(),
      },
      {
        'title': 'حجز',
        'subtitle': 'طاولة',
        'icon': Icons.table_restaurant,
        'color': Colors.orange,
        'page': const TableBookingPage(),
      },
      {
        'title': 'طلب',
        'subtitle': 'مسبق',
        'icon': Icons.schedule,
        'color': AppColors.primaryColor,
        'page': const PreOrderPage(),
      },
    ];

    return SizedBox(
      height: Responsive.isMobile(context) ? 120 : 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 20)),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          final hasSubtitle = (action['subtitle'] as String).isNotEmpty;
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => action['page'] as Widget),
              );
            },
            child: Container(
              width: Responsive.isMobile(context) ? 90 : 100,
              margin: EdgeInsets.only(right: Responsive.spacing(context, 10)),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing(context, 6),
                vertical: Responsive.spacing(context, 10),
              ),
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: Responsive.iconSize(context, 20),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 8)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          action['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Responsive.fontSize(context, 11),
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasSubtitle) ...[
                          const SizedBox(height: 3),
                          Text(
                            action['subtitle'] as String,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Responsive.fontSize(context, 10),
                              fontWeight: FontWeight.w500,
                              color: AppColors.subtleText,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 20)),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "ابحث عن منتج...",
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.subtleText.withValues(alpha: 0.6),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.primaryColor,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    color: AppColors.subtleText,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الفئات",
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: Responsive.fontSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 15)),
        SizedBox(
          height: Responsive.categoryHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 20)),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedCategoryIndex == index;
              final double start = (0.0 + (index * 0.04)).clamp(0.0, 1.0);
              final double end = (start + 0.25).clamp(0.0, 1.0);
              final anim = CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  0.30 + start * 0.20,
                  0.30 + end * 0.20,
                  curve: Curves.easeOut,
                ),
              );

              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(anim),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color.lerp(
                                AppColors.primaryColor,
                                Colors.orange,
                                0.6,
                              )!
                            : AppColors.whiteBackground,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.whiteText
                                : AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    final products = _filteredProducts;
    final crossAxisCount = Responsive.gridColumns(context);
    final spacing = Responsive.spacing(context, 15);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: Responsive.iconSize(context, 64),
              color: AppColors.subtleText.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              "لا توجد منتجات",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.fontSize(context, 16),
                color: AppColors.subtleText,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 8)),
            Text(
              "جرب البحث بكلمات مختلفة",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.fontSize(context, 14),
                color: AppColors.subtleText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _productsAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
            .animate(_productsAnim),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 20)),
          child: GridView.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: Responsive.cardAspectRatio(context),
            ),
            itemBuilder: (context, index) {
              final double baseStart = (index * 0.08);
              final double start = (0.50 + baseStart).clamp(0.0, 1.0);
              final double end = (start + 0.25).clamp(0.0, 1.0);
              final anim = CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeOut),
              );

              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(anim),
                  child: BlocBuilder<FavoriteBloc, FavoriteState>(
                    builder: (context, favState) {
                      final product = products[index];
                      final isFav = favState.favoriteIds.contains(product.id);
                      return ProductCard(
                        product: product,
                        isFavorite: isFav,
                        useHero: false,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

