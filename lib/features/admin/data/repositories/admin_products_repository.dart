import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ty_cafe/features/admin/data/mock_data.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';

class AdminProductsRepository {
  final FirebaseFirestore firestore;

  AdminProductsRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('products');

  Stream<List<ProductModel>> watchProducts() {
    return _collection
        .where('isActive', isEqualTo: true) // فقط المنتجات النشطة
        .orderBy('order', descending: false) // ترتيب حسب order
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  {
                    ...doc.data(),
                    'id': doc.id,
                  },
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> addProduct(ProductModel product) async {
    final doc = _collection.doc();
    final payload = product.copyWith(id: doc.id).toMap();
    
    // الحصول على عدد المنتجات الحالي لتحديد الترتيب
    final snapshot = await _collection.count().get();
    final order = snapshot.count;
    
    await doc.set({
      ...payload,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'order': order, // ترتيب المنتج
      'isActive': true, // المنتج نشط
      'views': 0, // عدد المشاهدات
      'sales': 0, // عدد المبيعات
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _collection.doc(product.id).set(
      {
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true, // التأكد من أن المنتج نشط
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteProduct(String productId) async {
    // بدلاً من الحذف، نقوم بتعطيل المنتج (soft delete)
    await _collection.doc(productId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // دالة لإضافة المنتجات التجريبية إلى Firebase
  Future<void> addMockProductsToFirebase() async {
    final mockProducts = MockData.getMockProducts();
    final batch = firestore.batch();
    
    for (int i = 0; i < mockProducts.length; i++) {
      final product = mockProducts[i];
      final doc = _collection.doc();
      final payload = product.copyWith(id: doc.id).toMap();
      
      batch.set(doc, {
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'order': i, // ترتيب المنتج
        'isActive': true,
        'views': 0,
        'sales': 0,
      });
    }
    
    await batch.commit();
  }

  // دالة لإعادة ترتيب المنتجات
  Future<void> reorderProducts(List<String> productIds) async {
    final batch = firestore.batch();
    
    for (int i = 0; i < productIds.length; i++) {
      final docRef = _collection.doc(productIds[i]);
      batch.update(docRef, {
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }
}
