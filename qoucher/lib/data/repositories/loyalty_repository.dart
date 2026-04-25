import 'package:qoucher/data/datasources/loyalty_remote_datasource.dart';
import 'package:qoucher/data/models/loyalty_account.dart';
import 'package:qoucher/data/models/loyalty_transaction.dart';

class LoyaltyRepository {
  final LoyaltyRemoteDatasource remoteDatasource;

  LoyaltyRepository({
    required this.remoteDatasource,
  });

  Future<List<LoyaltyAccount>> getUserLoyaltyAccounts(String userId) async {
    final result = await remoteDatasource.getUserLoyaltyAccounts(userId);

    return result
        .map((accountMap) => LoyaltyAccount.fromMap(accountMap))
        .toList();
  }

  Future<LoyaltyAccount> getLoyaltyAccount({
    required String userId,
    required String merchantId,
  }) async {
    final result = await remoteDatasource.getLoyaltyAccount(
      userId: userId,
      merchantId: merchantId,
    );

    return LoyaltyAccount.fromMap(result);
  }

  Future<String> addPoints({
    required String userId,
    required String merchantId,
    required int amount,
  }) async {
    final result = await remoteDatasource.addPoints(
      userId: userId,
      merchantId: merchantId,
      amount: amount,
    );

    return result['message']?.toString() ?? 'Punkte hinzugefügt.';
  }

  Future<String> addStamp({
    required String userId,
    required String merchantId,
  }) async {
    final result = await remoteDatasource.addStamp(
      userId: userId,
      merchantId: merchantId,
    );

    return result['message']?.toString() ?? 'Stempel hinzugefügt.';
  }

  Future<String> redeemReward({
    required String userId,
    required String merchantId,
    required String rewardId,
  }) async {
    final result = await remoteDatasource.redeemReward(
      userId: userId,
      merchantId: merchantId,
      rewardId: rewardId,
    );

    return result['message']?.toString() ?? 'Belohnung eingelöst.';
  }

  Future<List<LoyaltyTransaction>> getTransactions({
    required String userId,
    String? merchantId,
  }) async {
    final result = await remoteDatasource.getTransactions(
      userId: userId,
      merchantId: merchantId,
    );

    return result
        .map((transactionMap) => LoyaltyTransaction.fromMap(transactionMap))
        .toList();
  }
}