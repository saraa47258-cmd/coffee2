import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CartRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  String? get _maybeUid => auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _maybeUid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('cartItems');
  }

  @override
  Future<void> addItem(CartItem item) async {
    final collection = _collection;
    if (collection == null) return;
    final docRef = collection.doc(item.id);
    await firestore.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      int currentQty = 0;
      if (snapshot.exists) {
        final rawQuantity = snapshot.data()?['quantity'];
        if (rawQuantity is int) {
          currentQty = rawQuantity;
        } else if (rawQuantity is num) {
          currentQty = rawQuantity.toInt();
        } else {
          currentQty = int.tryParse(rawQuantity?.toString() ?? '0') ?? 0;
        }
      }
      final updated = item.copyWith(quantity: currentQty + item.quantity);
      txn.set(docRef, {
        ...updated.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> clear() async {
    final collection = _collection;
    if (collection == null) return;
    final batch = firestore.batch();
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> removeItem(String productId) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(productId).delete();
  }

  @override
  Future<void> updateItem(CartItem item) async {
    final collection = _collection;
    if (collection == null) return;
    await collection.doc(item.id).set(
      {
        ...item.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<CartItem>> getItems() async {
    final collection = _collection;
    if (collection == null) return [];
    final snapshot = await collection.orderBy('updatedAt', descending: true).get();
    return snapshot.docs
        .map(
          (doc) => CartItem.fromMap(
            {
              ...doc.data(),
              'id': doc.id,
            },
          ),
        )
        .toList(growable: false);
  }
}
