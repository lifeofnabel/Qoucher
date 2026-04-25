import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantActionsRemoteDatasource {
  MerchantActionsRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _actions =>
      _firestore.collection('merchant_actions');

  Future<String> createAction({
    required String merchantId,
    required String shopName,
    required String type,
    required String title,
    required String subtitle,
    required String description,
    required String status,
    required bool isVisible,
    String? imageUrl,
    String? linkedItemId,
    Map<String, dynamic>? rules,
    DateTime? startsAt,
    DateTime? endsAt,
  }) async {
    final now = Timestamp.now();

    final doc = await _actions.add({
      'merchantId': merchantId,
      'shopName': shopName,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'status': status, // draft / active / paused / archived
      'isVisible': isVisible,
      'imageUrl': imageUrl,
      'linkedItemId': linkedItemId,
      'rules': rules ?? {},
      'startsAt': startsAt != null ? Timestamp.fromDate(startsAt) : null,
      'endsAt': endsAt != null ? Timestamp.fromDate(endsAt) : null,
      'createdAt': now,
      'updatedAt': now,
    });

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getMerchantActions(
      String merchantId, {
        String? status,
        String? type,
      }) async {
    Query<Map<String, dynamic>> query = _actions
        .where('merchantId', isEqualTo: merchantId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }

  Future<void> updateAction(
      String actionId, {
        String? title,
        String? subtitle,
        String? description,
        String? imageUrl,
        String? linkedItemId,
        Map<String, dynamic>? rules,
        DateTime? startsAt,
        DateTime? endsAt,
      }) async {
    final data = <String, dynamic>{
      'updatedAt': Timestamp.now(),
    };

    if (title != null) data['title'] = title;
    if (subtitle != null) data['subtitle'] = subtitle;
    if (description != null) data['description'] = description;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (linkedItemId != null) data['linkedItemId'] = linkedItemId;
    if (rules != null) data['rules'] = rules;
    if (startsAt != null) data['startsAt'] = Timestamp.fromDate(startsAt);
    if (endsAt != null) data['endsAt'] = Timestamp.fromDate(endsAt);

    await _actions.doc(actionId).update(data);
  }

  Future<void> activateAction(String actionId) async {
    await _actions.doc(actionId).update({
      'status': 'active',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> pauseAction(String actionId) async {
    await _actions.doc(actionId).update({
      'status': 'paused',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> archiveAction(String actionId) async {
    await _actions.doc(actionId).update({
      'status': 'archived',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deactivateToArchive(String actionId) async {
    await archiveAction(actionId);
  }
}