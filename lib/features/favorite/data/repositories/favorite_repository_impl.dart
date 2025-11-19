import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoriteRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('favorites');
  }

  @override
  Future<Set<String>> fetchFavorites() async {
    final collection = _collection;
    if (collection == null) return <String>{};
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  @override
  Future<void> setFavorite(String productId, bool isFavorite) async {
    final collection = _collection;
    if (collection == null) return;
    final docRef = collection.doc(productId);
    if (isFavorite) {
      await docRef.set({
        'productId': productId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await docRef.delete();
    }
  }

  @override
  Future<void> clearFavorites() async {
    final collection = _collection;
    if (collection == null) return;
    final snapshot = await collection.get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

