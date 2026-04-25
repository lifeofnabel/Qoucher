import 'package:qoucher/data/datasources/reward_remote_datasource.dart';
import 'package:qoucher/data/models/reward.dart';

class RewardRepository {
  final RewardRemoteDatasource remoteDatasource;

  RewardRepository({
    required this.remoteDatasource,
  });

  Future<List<Reward>> getRewardsByMerchant(String merchantId) async {
    final result = await remoteDatasource.getRewardsByMerchant(merchantId);

    return result
        .map((rewardMap) => Reward.fromMap(rewardMap))
        .toList();
  }

  Future<Reward> getRewardById(String rewardId) async {
    final result = await remoteDatasource.getRewardById(rewardId);
    return Reward.fromMap(result);
  }

  Future<Reward> createReward({
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    int? costPoints,
    int? requiredStamps,
    required bool isActive,
  }) async {
    final result = await remoteDatasource.createReward(
      merchantId: merchantId,
      title: title,
      description: description,
      rewardType: rewardType,
      costPoints: costPoints,
      requiredStamps: requiredStamps,
      isActive: isActive,
    );

    return Reward.fromMap(result);
  }

  Future<Reward> updateReward({
    required String rewardId,
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    int? costPoints,
    int? requiredStamps,
    required bool isActive,
  }) async {
    final result = await remoteDatasource.updateReward(
      rewardId: rewardId,
      merchantId: merchantId,
      title: title,
      description: description,
      rewardType: rewardType,
      costPoints: costPoints,
      requiredStamps: requiredStamps,
      isActive: isActive,
    );

    return Reward.fromMap(result);
  }

  Future<void> deleteReward(String rewardId) async {
    await remoteDatasource.deleteReward(rewardId);
  }
}