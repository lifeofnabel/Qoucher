import 'package:qoucher/data/datasources/merchant_remote_datasource.dart';
import 'package:qoucher/data/models/merchant.dart';

class MerchantRepository {
  final MerchantRemoteDatasource remoteDatasource;

  MerchantRepository({
    required this.remoteDatasource,
  });

  Future<List<Merchant>> getAllMerchants() async {
    final result = await remoteDatasource.getAllMerchants();

    return result
        .map((merchantMap) => Merchant.fromMap(merchantMap))
        .toList();
  }

  Future<Merchant> getMerchantById(String merchantId) async {
    final result = await remoteDatasource.getMerchantById(merchantId);
    return Merchant.fromMap(result);
  }

  Future<Merchant> createMerchant({
    required String ownerId,
    required String name,
    required String category,
    required String area,
    required String description,
    required String loyaltyType,
  }) async {
    final result = await remoteDatasource.createMerchant(
      ownerId: ownerId,
      name: name,
      category: category,
      area: area,
      description: description,
      loyaltyType: loyaltyType,
    );

    return Merchant.fromMap(result);
  }

  Future<Merchant> updateMerchant({
    required String merchantId,
    required String name,
    required String category,
    required String area,
    required String description,
    required String loyaltyType,
    required bool isActive,
  }) async {
    final result = await remoteDatasource.updateMerchant(
      merchantId: merchantId,
      name: name,
      category: category,
      area: area,
      description: description,
      loyaltyType: loyaltyType,
      isActive: isActive,
    );

    return Merchant.fromMap(result);
  }
}