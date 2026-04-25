class Formatters {
  Formatters._();

  static String capitalize(String value) {
    if (value.trim().isEmpty) return value;
    final text = value.trim();
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeWords(String value) {
    if (value.trim().isEmpty) return value;

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map(capitalize)
        .join(' ');
  }

  static String username(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  static String cleanText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String shortText(String value, {int maxLength = 60}) {
    final text = cleanText(value);
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trim()}...';
  }

  static String price(num value) {
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  static String points(int value) {
    return '$value Punkte';
  }

  static String stamps(int value) {
    return value == 1 ? '1 Stempel' : '$value Stempel';
  }

  static String roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'merchant':
        return 'Merchant';
      case 'customer':
        return 'Kunde';
      default:
        return capitalize(role);
    }
  }

  static String loyaltyTypeLabel(String loyaltyType) {
    switch (loyaltyType.toLowerCase()) {
      case 'points':
        return 'Punkte';
      case 'stamps':
        return 'Stempel';
      default:
        return capitalize(loyaltyType);
    }
  }
}