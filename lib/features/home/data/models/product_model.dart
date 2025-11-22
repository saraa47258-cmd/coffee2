class ProductModel {
  final String id;
  final String name;
  final String price;
  final String originalPrice;
  final String tag;
  final String tagColor;
  final String image;
  final String rating;
  final String description;
  final String category;
  final bool hasDiscount;
  final double discountPercent;
  final int quantity;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.tag,
    required this.tagColor,
    required this.image,
    this.rating = '4.9/5',
    this.description = '',
    this.category = 'All',
    this.hasDiscount = false,
    this.discountPercent = 0.0,
    this.quantity = 0,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      price: (map['price'] ?? '').toString(),
      originalPrice: (map['originalPrice'] ?? '').toString(),
      tag: (map['tag'] ?? '').toString(),
      tagColor: (map['tagColor'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      rating: (map['rating'] ?? '4.9/5').toString(),
      description: (map['description'] ?? '').toString(),
      category: (map['category'] ?? 'All').toString(),
      hasDiscount: (map['hasDiscount'] as bool?) ?? false,
      discountPercent: (map['discountPercent'] is num)
          ? (map['discountPercent'] as num).toDouble()
          : 0.0,
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "originalPrice": originalPrice,
      "tag": tag,
      "tagColor": tagColor,
      "image": image,
      "rating": rating,
      "description": description,
      "category": category,
      "hasDiscount": hasDiscount,
      "discountPercent": discountPercent,
      "quantity": quantity,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? price,
    String? originalPrice,
    String? tag,
    String? tagColor,
    String? image,
    String? rating,
    String? description,
    String? category,
    bool? hasDiscount,
    double? discountPercent,
    int? quantity,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      category: category ?? this.category,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      discountPercent: discountPercent ?? this.discountPercent,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, hasDiscount: $hasDiscount, discountPercent: $discountPercent)';
  }
}
