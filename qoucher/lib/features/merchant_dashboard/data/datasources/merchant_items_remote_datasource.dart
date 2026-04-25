import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantItemsRemoteDatasource {
  MerchantItemsRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('merchant_items');

  Future<String> createItem({
    required String merchantId,
    required String title,
    required String description,
    required double originalPrice,
    required String imageUrl,
    required String category,
    bool isActive = true,
  }) async {
    final now = Timestamp.now();

    final doc = await _items.add({
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      'createdAt': now,
      'updatedAt': now,
    });

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getMerchantItems(String merchantId) async {
    final snapshot = await _items
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }

  Future<void> updateItem(
      String itemId, {
        String? title,
        String? description,
        double? originalPrice,
        String? imageUrl,
        String? category,
        bool? isActive,
      }) async {
    final data = <String, dynamic>{
      'updatedAt': Timestamp.now(),
    };

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (originalPrice != null) data['originalPrice'] = originalPrice;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (category != null) data['category'] = category;
    if (isActive != null) data['isActive'] = isActive;

    await _items.doc(itemId).update(data);
  }

  Future<void> setItemActive(String itemId, bool isActive) async {
    await _items.doc(itemId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
    });
  }
}