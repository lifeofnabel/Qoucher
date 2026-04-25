import 'package:qoucher/data/datasources/deal_remote_datasource.dart';
import 'package:qoucher/data/models/deal.dart';

class DealRepository {
  final DealRemoteDatasource remoteDatasource;

  DealRepository({
    required this.remoteDatasource,
  });

  Future<List<Deal>> getHotDeals() async {
    final result = await remoteDatasource.getHotDeals();

    return result
        .map((dealMap) => Deal.fromMap(dealMap))
        .toList();
  }

  Future<List<Deal>> getDealsByMerchant(String merchantId) async {
    final result = await remoteDatasource.getDealsByMerchant(merchantId);

    return result
        .map((dealMap) => Deal.fromMap(dealMap))
        .toList();
  }

  Future<Deal> createDeal({
    required String merchantId,
    required String title,
    required String description,
    required String category,
    required String area,
    required bool isHot,
    required bool isActive,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    final result = await remoteDatasource.createDeal(
      merchantId: merchantId,
      title: title,
      description: description,
      category: category,
      area: area,
      isHot: isHot,
      isActive: isActive,
      startAt: startAt,
      endAt: endAt,
    );

    return Deal.fromMap(result);
  }

  Future<Deal> updateDeal({
    required String dealId,
    required String merchantId,
    required String title,
    required String description,
    required String category,
    required String area,
    required bool isHot,
    required bool isActive,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    final result = await remoteDatasource.updateDeal(
      dealId: dealId,
      merchantId: merchantId,
      title: title,
      description: description,
      category: category,
      area: area,
      isHot: isHot,
      isActive: isActive,
      startAt: startAt,
      endAt: endAt,
    );

    return Deal.fromMap(result);
  }

  Future<void> deleteDeal(String dealId) async {
    await remoteDatasource.deleteDeal(dealId);
  }
}