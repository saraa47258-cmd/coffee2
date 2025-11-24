import 'package:flutter/material.dart';
import 'package:ty_cafe/features/home/data/datasources/product_data.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ProductComparisonPage extends StatefulWidget {
  const ProductComparisonPage({super.key});

  @override
  State<ProductComparisonPage> createState() => _ProductComparisonPageState();
}

class _ProductComparisonPageState extends State<ProductComparisonPage> {
  final List<String> _selectedProductIds = [];

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
          'مقارنة المنتجات',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: Responsive.fontSize(context, 22),
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        actions: [
          if (_selectedProductIds.length >= 2)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComparisonResultPage(
                      productIds: _selectedProductIds,
                    ),
                  ),
                );
              },
              child: Text(
                'مقارنة (${_selectedProductIds.length})',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
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
        child: ListView.builder(
          padding: EdgeInsets.all(Responsive.spacing(context, 20)),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            final isSelected = _selectedProductIds.contains(product.id);
            
            return Container(
              margin: EdgeInsets.only(bottom: Responsive.spacing(context, 15)),
              decoration: BoxDecoration(
                color: AppColors.whiteBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (_selectedProductIds.length < 4) {
                        _selectedProductIds.add(product.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يمكنك مقارنة 4 منتجات كحد أقصى'),
                          ),
                        );
                      }
                    } else {
                      _selectedProductIds.remove(product.id);
                    }
                  });
                },
                title: Text(
                  product.name,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      product.price,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    if (product.category.isNotEmpty)
                      Text(
                        product.category,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Responsive.fontSize(context, 12),
                          color: AppColors.subtleText,
                        ),
                      ),
                  ],
                ),
                secondary: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.subtleText.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.image),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ComparisonResultPage extends StatelessWidget {
  final List<String> productIds;

  const ComparisonResultPage({super.key, required this.productIds});

  @override
  Widget build(BuildContext context) {
    final products = productList
        .where((p) => productIds.contains(p.id))
        .toList();

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
          'نتائج المقارنة',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.spacing(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // جدول المقارنة
              _buildComparisonTable(context, products),
              const SizedBox(height: 20),
              // أفضل سعر
              _buildBestPriceCard(context, products),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context, List<ProductModel> products) {
    return Container(
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
      child: Table(
        border: TableBorder.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
            ),
            children: [
              const TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'الميزة',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...products.map((p) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
          ),
          // Price
          TableRow(
            children: [
              const TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'السعر',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ),
              ...products.map((p) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        p.price,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
          ),
          // Category
          TableRow(
            children: [
              const TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'الفئة',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ),
              ...products.map((p) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        p.category,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
          ),
          // Rating
          TableRow(
            children: [
              const TableCell(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'التقييم',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ),
              ...products.map((p) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        p.rating,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestPriceCard(BuildContext context, List<ProductModel> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    
    // استخراج الأسعار ومقارنتها
    final prices = products.map((p) {
      final priceStr = p.price.replaceAll(' ر.ع.', '').trim();
      return double.tryParse(priceStr) ?? 0.0;
    }).toList();
    
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final bestProduct = products[prices.indexOf(minPrice)];

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.1),
            AppColors.whiteBackground,
          ],
        ),
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
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: Responsive.iconSize(context, 24),
              ),
              const SizedBox(width: 10),
              Text(
                'أفضل سعر',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            bestProduct.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'السعر: ${bestProduct.price}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Responsive.fontSize(context, 16),
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

