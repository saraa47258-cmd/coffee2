import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ty_cafe/features/home/data/models/product_model.dart';

class AdminProductsRepository {
  final FirebaseFirestore firestore;

  AdminProductsRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('products');

  Stream<List<ProductModel>> watchProducts() {
    return _collection
        .orderBy('createdAt', descending: true)
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
    await doc.set({
      ...payload,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _collection.doc(product.id).set(
      {
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteProduct(String productId) async {
    await _collection.doc(productId).delete();
  }
}

