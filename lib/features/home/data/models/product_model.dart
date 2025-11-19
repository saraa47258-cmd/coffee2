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

  ProductModel({
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
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, category: $category, price: $price)';
  }
}
