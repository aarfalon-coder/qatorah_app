import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Helpers {
  // ═══ تنسيق التاريخ ═══
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${formatDate(date)} - $hour:$minute';
  }

  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ═══ الوقت النسبي ═══
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  // ═══ تنسيق السعر ═══
  static String formatPrice(double price, {String currency = 'د.أ'}) {
    return '${price.toStringAsFixed(2)} $currency';
  }

  static String formatPriceShort(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toStringAsFixed(0);
  }

  // ═══ تنسيق الأرقام ═══
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // ═══ تنسيق المسافة ═══
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} متر';
    }
    return '${km.toStringAsFixed(1)} كم';
  }

  // ═══ تنسيق المدة ═══
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    }
    return '${duration.inMinutes} دقيقة';
  }

  static String formatDaysRemaining(int days) {
    if (days <= 0) return 'منتهي';
    if (days == 1) return 'يوم واحد';
    if (days == 2) return 'يومان';
    if (days < 11) return '$days أيام';
    return '$days يوماً';
  }

  // ═══ اختصار النص ═══
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ═══ الحصول على الأحرف الأولى ═══
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ═══ التحقق من الوقت ═══
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  // ═══ الحصول على لون الحالة ═══
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_approval':
        return const Color(0xFFFFA726);
      case 'accepted':
      case 'active':
        return const Color(0xFF4CAF50);
      case 'in_progress':
      case 'in_transit':
      case 'on_the_way':
        return const Color(0xFF2196F3);
      case 'completed':
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'cancelled':
      case 'failed':
      case 'rejected':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // ═══ الحصول على أيقونة الحالة ═══
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_approval':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'in_progress':
      case 'in_transit':
      case 'on_the_way':
        return Icons.local_shipping;
      case 'completed':
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
      case 'failed':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  // ═══ توليد معرف فريد ═══
  static String generateId({String prefix = ''}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '$prefix${timestamp}_$random';
  }

  // ═══ التحقق من صحة الرابط ═══
  static bool isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  // ═══ نسخ إلى الحافظة ═══
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم النسخ'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // ═══ إخفاء جزء من رقم الهاتف ═══
  static String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}';
  }

  // ═══ إخفاء البريد الإلكتروني ═══
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    if (parts[0].length <= 2) return email;
    final masked = '${parts[0].substring(0, 2)}***';
    return '$masked@${parts[1]}';
  }
}