class FirestoreService {
  Future<List<Map<String, dynamic>>> getCollection(String collectionName) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [];
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collectionName,
    required String documentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    return null;
  }

  Future<Map<String, dynamic>> createDocument({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    return {
      'collection': collectionName,
      'documentId': documentId,
      ...data,
    };
  }

  Future<Map<String, dynamic>> updateDocument({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    return {
      'collection': collectionName,
      'documentId': documentId,
      ...data,
    };
  }

  Future<void> deleteDocument({
    required String collectionName,
    required String documentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}