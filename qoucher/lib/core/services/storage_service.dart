class StorageService {
  Future<String> uploadFile({
    required String path,
    required String fileName,
    List<int>? fileBytes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return 'https://dummy.qoucher.app/storage/$path/$fileName';
  }

  Future<void> deleteFile({
    required String path,
    required String fileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<String> getFileUrl({
    required String path,
    required String fileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return 'https://dummy.qoucher.app/storage/$path/$fileName';
  }
}