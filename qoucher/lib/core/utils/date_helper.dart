class DateHelper {
  DateHelper._();

  static String formatDate(DateTime? date) {
    if (date == null) return '-';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';

    final formattedDate = formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$formattedDate • $hour:$minute';
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '-';

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  static bool isExpired(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  static bool isRunning({
    DateTime? startAt,
    DateTime? endAt,
  }) {
    final now = DateTime.now();

    if (startAt != null && now.isBefore(startAt)) return false;
    if (endAt != null && now.isAfter(endAt)) return false;

    return true;
  }

  static String relativeText(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'gerade eben';
    } else if (difference.inMinutes < 60) {
      return 'vor ${difference.inMinutes} Min';
    } else if (difference.inHours < 24) {
      return 'vor ${difference.inHours} Std';
    } else if (difference.inDays == 1) {
      return 'gestern';
    } else if (difference.inDays < 7) {
      return 'vor ${difference.inDays} Tagen';
    }

    return formatDate(date);
  }
}