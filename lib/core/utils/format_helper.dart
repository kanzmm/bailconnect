import 'package:intl/intl.dart';

// Format utilities
class FormatHelper {
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'Fc ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy - HH:mm', 'fr_FR').format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }

  static String formatPhoneNumber(String phone) {
    // Format pour DRC: +243 XXX XXX XXX
    if (phone.length < 9) return phone;
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      return '+243 ${cleaned.substring(1)}';
    }
    return '+243 $cleaned';
  }
}
