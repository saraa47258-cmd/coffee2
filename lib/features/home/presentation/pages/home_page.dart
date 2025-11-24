import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:ty_cafe/features/home/data/datasources/product_data.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import 'package:ty_cafe/features/home/presentation/pages/all_products_page.dart';
import 'package:ty_cafe/features/home/presentation/widgets/product_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    "All",
    "Hot Coffee",
    "Cold Coffee",
    "Milk Coffee",
    "Blended",
  ];

  late final AnimationController _controller;
  late final Animation<double> _appBarAnim;
  late final Animation<double> _bannerAnim;
  late final Animation<double> _categoriesAnim;
  late final Animation<double> _productsAnim;
  late final PageController _bannerPageController;
  int _currentBanner = 0;
  Timer? _bannerTimer;

  Timer? _promoTimer;
  bool _promoShown = false;

  final List<Map<String, String>> _banners = [
    {
      'titleSmall': 'Today Only',
      'titleBig': '65% OFF',
      'subtitle': 'Super Discount',
      'image': 'assets/images/coffe.webp',
      'cta': 'Order Now',
    },
    {
      'titleSmall': 'New Arrival',
      'titleBig': 'Iced Caramel',
      'subtitle': 'Limited Edition',
      'image': 'assets/images/ice.png',
      'cta': 'Try Now',
    },
    {
      'titleSmall': 'Top Pick',
      'titleBig': 'Vanilla Latte',
      'subtitle': 'Barista Choice',
      'image': 'assets/images/vlatte.png',
      'cta': 'Shop Now',
    },
  ];

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
    _bannerAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.50, curve: Curves.easeOut),
    );
    _categoriesAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.65, curve: Curves.easeOut),
    );
    _productsAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _bannerPageController = PageController(viewportFraction: 1.0);
    _currentBanner = 0;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final next = (_currentBanner + 1) % _banners.length;
        _bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    _bannerPageController.addListener(() {
      final page = _bannerPageController.page?.round() ?? 0;
      if (page != _currentBanner) {
        setState(() => _currentBanner = page);
      }
    });

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promoTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        if (!_promoShown) {
          _promoShown = true;
          _showPromoDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _promoTimer?.cancel();

    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final selectedCategory = _categories[_selectedCategoryIndex];
    return productList.where((p) {
      return selectedCategory == 'All' || p.category == selectedCategory;
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

  void _showPromoDialog() {
    final banner = (_banners.isNotEmpty && _currentBanner < _banners.length)
        ? _banners[_currentBanner]
        : (_banners.isNotEmpty ? _banners[0] : null);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.65,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    if (banner != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          banner['image'] ?? 'assets/images/coffe.webp',
                          height: constraints.maxHeight * 0.65,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (banner != null)
                                Text(
                                  banner['titleSmall'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.subtleText,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              if (banner != null)
                                Text(
                                  banner['titleBig'] ?? 'Special Promo',
                                  style: const TextStyle(
                                    fontFamily: 'PlayfairDisplay',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (banner != null)
                                Text(
                                  banner['subtitle'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: AppColors.subtleText,
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.lerp(
                                        AppColors.primaryColor,
                                        Colors.orange,
                                        0.6,
                                      )!,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      log(
                                        '${banner?['cta']} pressed from promo dialog',
                                      );
                                    },
                                    child: Text(
                                      banner?['cta'] ?? 'Order Now',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: AppColors.whiteText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: Responsive.padding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Responsive.spacing(context, 10)),
                      _buildEnterAnimation(
                        child: _buildAppBar(context),
                        anim: _appBarAnim,
                      ),
                      SizedBox(height: Responsive.spacing(context, 25)),
                      _buildEnterAnimation(
                        child: _buildPromoBanner(context),
                        anim: _bannerAnim,
                        startOffset: 10,
                      ),
                      SizedBox(height: Responsive.spacing(context, 25)),
                      _buildEnterAnimation(
                        child: _buildCategories(context),
                        anim: _categoriesAnim,
                      ),
                      SizedBox(height: Responsive.spacing(context, 25)),
                      _buildProductGrid(context),
                      SizedBox(height: Responsive.spacing(context, 20)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final avatarSize = Responsive.isMobile(context) ? 25.0 : 30.0;
    final iconSize = Responsive.iconSize(context, 28);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
            ),
            SizedBox(width: Responsive.spacing(context, 15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fluty",
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: Responsive.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 2)),
                Text(
                  "Good Morning 👋",
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
            Icons.notifications_outlined,
            color: AppColors.darkText,
            size: iconSize,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return SizedBox(
      height: Responsive.bannerHeight(context),
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,
            itemBuilder: (context, i) {
              final item = _banners[i];
              return GestureDetector(
                onTap: () {
                  log('Tapped banner $i: ${item['titleBig']}');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.5),
                        AppColors.primaryColor.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['titleSmall'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.subtleText,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item['titleBig'] ?? '',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: Responsive.fontSize(context, 24),
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              item['subtitle'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.subtleText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                log('${item['cta']} pressed for banner $i');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor.withValues(
                                        alpha: 0.6,
                                      ),
                                      Color.lerp(
                                        AppColors.primaryColor,
                                        Colors.orange,
                                        0.6,
                                      )!,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item['cta'] ?? 'Order',
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
                      Expanded(
                        flex: 2,
                        child: Hero(
                          tag: 'banner_image_$i',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['image'] ?? 'assets/images/coffe.webp',
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset(
                                'assets/images/coffe.webp',
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                final isActive = i == _currentBanner;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.whiteText
                        : AppColors.whiteText.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Categories",
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: Responsive.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllProductsPage(
                      initialCategory: _categories[_selectedCategoryIndex],
                    ),
                  ),
                );
              },
              child: const Text(
                "See all",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 15)),
        SizedBox(
          height: Responsive.categoryHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedCategoryIndex == index;
              final double start = (0.0 + (index * 0.04)).clamp(0.0, 1.0);
              final double end = (start + 0.25).clamp(0.0, 1.0);
              final anim = CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  0.50 + start * 0.15,
                  0.50 + end * 0.15,
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

    return FadeTransition(
      opacity: _productsAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
              ),
            ),
        child: GridView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: Responsive.cardAspectRatio(context),
          ),
          itemBuilder: (context, index) {
            final double baseStart = (index * 0.08);
            final double start = (0.65 + baseStart).clamp(0.0, 1.0);
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
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
