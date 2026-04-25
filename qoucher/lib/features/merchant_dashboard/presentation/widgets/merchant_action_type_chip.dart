import 'package:flutter/material.dart';

class MerchantActionTypeChip extends StatelessWidget {
  const MerchantActionTypeChip({
    super.key,
    required this.label,
  });

  final String label;

  String get _normalized => label.trim().toLowerCase();

  Color _backgroundColor() {
    switch (_normalized) {
      case 'deal':
        return Colors.blue.withOpacity(0.12);
      case 'reward':
        return Colors.purple.withOpacity(0.12);
      case 'coupon':
        return Colors.teal.withOpacity(0.12);
      case 'points_booster':
      case 'punkte-booster':
        return Colors.amber.withOpacity(0.18);
      case 'stamp_campaign':
      case 'stempelaktion':
        return Colors.orange.withOpacity(0.16);
      case 'free_item':
      case 'gratisartikel':
        return Colors.green.withOpacity(0.12);
      case 'discount_item':
      case 'rabatt auf artikel':
        return Colors.red.withOpacity(0.12);
      case 'discount_all':
      case 'rabatt auf alles':
        return Colors.red.withOpacity(0.18);
      case 'two_for_one':
      case '2 für 1':
        return Colors.indigo.withOpacity(0.12);
      case 'two_plus_one':
      case '2+1':
      case '2 + 1':
        return Colors.indigo.withOpacity(0.18);
      case 'buy_x_get_y':
      case 'kauf x → y':
        return Colors.cyan.withOpacity(0.14);
      default:
        return Colors.grey.withOpacity(0.14);
    }
  }

  Color _textColor() {
    switch (_normalized) {
      case 'deal':
        return Colors.blue.shade700;
      case 'reward':
        return Colors.purple.shade700;
      case 'coupon':
        return Colors.teal.shade700;
      case 'points_booster':
      case 'punkte-booster':
        return Colors.amber.shade900;
      case 'stamp_campaign':
      case 'stempelaktion':
        return Colors.orange.shade900;
      case 'free_item':
      case 'gratisartikel':
        return Colors.green.shade700;
      case 'discount_item':
      case 'rabatt auf artikel':
      case 'discount_all':
      case 'rabatt auf alles':
        return Colors.red.shade700;
      case 'two_for_one':
      case '2 für 1':
      case 'two_plus_one':
      case '2+1':
      case '2 + 1':
        return Colors.indigo.shade700;
      case 'buy_x_get_y':
      case 'kauf x → y':
        return Colors.cyan.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  String _displayLabel() {
    switch (_normalized) {
      case 'deal':
        return 'Deal';
      case 'reward':
        return 'Reward';
      case 'coupon':
        return 'Coupon';
      case 'points_booster':
        return 'Punkte-Booster';
      case 'stamp_campaign':
        return 'Stempelaktion';
      case 'free_item':
        return 'Gratisartikel';
      case 'discount_item':
        return 'Rabatt auf Artikel';
      case 'discount_all':
        return 'Rabatt auf alles';
      case 'two_for_one':
        return '2 für 1';
      case 'two_plus_one':
        return '2 + 1';
      case 'buy_x_get_y':
        return 'Kauf X → Y';
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _displayLabel(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _textColor(),
        ),
      ),
    );
  }
}