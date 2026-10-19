/// ═══════════════════════════════════════════════════════════
///  Region Model — العقل الجغرافي لنظام إعلانات قطوره
///  يحدد: المحافظات، المناطق الكبرى، وقواعد التغطية حسب نوع الإعلان
/// ═══════════════════════════════════════════════════════════
library;

/// المناطق الكبرى الثلاث في الأردن
enum Region {
  north('الشمال'),
  center('الوسط'),
  south('الجنوب');

  const Region(this.displayName);
  final String displayName;
}

/// المحافظات الأردنية مع رمزها ومنطقتها
enum Governorate {
  // ── الشمال ──
  irbid('irbid', 'إربد', Region.north),
  ramtha('ramtha', 'الرمثا', Region.north),
  jerash('jerash', 'جرش', Region.north),
  ajloun('ajloun', 'عجلون', Region.north),
  mafraq('mafraq', 'المفرق', Region.north),

  // ── الوسط ──
  amman('amman', 'عمان', Region.center),
  zarqa('zarqa', 'الزرقاء', Region.center),
  madaba('madaba', 'مادبا', Region.center),
  balqa('balqa', 'البلقاء', Region.center),

  // ── الجنوب ──
  karak('karak', 'الكرك', Region.south),
  maan('maan', 'معان', Region.south),
  aqaba('aqaba', 'العقبة', Region.south),
  tafila('tafila', 'الطفيلة', Region.south);

  const Governorate(this.code, this.displayName, this.region);

  final String code;        // الرمز المستخدم في Firestore (irbid, amman...)
  final String displayName; // الاسم بالعربي للعرض
  final Region region;      // المنطقة الكبرى التابعة لها

  /// البحث عن محافظة بواسطة رمزها
  static Governorate? fromCode(String? code) {
    if (code == null) return null;
    for (final g in Governorate.values) {
      if (g.code == code) return g;
    }
    return null;
  }

  @override
  String toString() => displayName;
}

/// ═══ أدوات مساعدة لحساب التغطية الجغرافية ═══
class Regions {
  Regions._(); // ممنوع التأسيس

  /// أعضاء كل منطقة كبرى
  static List<Governorate> membersOf(Region region) =>
      Governorate.values.where((g) => g.region == region).toList();

  /// ═══ قاعدة التغطية حسب نوع الإعلان ═══
  /// [free]     → محافظة المزود فقط
  /// [premium]  → كل محافظات نفس المنطقة الكبرى
  /// [qatorah]  → كل المملكة ("all")
  ///
  /// ترجع قائمة رموز المحافظات اللي بيظهر فيها الإعلان
  static List<String> coverageFor(Governorate governorate, String type) {
    switch (type) {
      case 'free':
        return [governorate.code];
      case 'premium':
        return membersOf(governorate.region).map((g) => g.code).toList();
      case 'qatorah':
        return ['all'];
      default:
        return [governorate.code];
    }
  }

  /// ═══ هل الإعلان ظاهر لمستخدم في محافظة معينة؟ ═══
  /// [coverage] قائمة الرموز المخزنة على الإعلان
  /// [customerGov] محافظة العميل الحالية
  static bool isVisibleTo(List<String> coverage, Governorate? customerGov) {
    if (coverage.contains('all')) return true;
    if (customerGov == null) return false;
    return coverage.contains(customerGov.code);
  }

  /// وصف نصي للتغطية (لعرضه في شاشة إنشاء الإعلان)
  static String describeCoverage(Governorate governorate, String type) {
    switch (type) {
      case 'free':
        return 'منطقتك فقط: ${governorate.displayName}';
      case 'premium':
        final names = membersOf(governorate.region)
            .map((g) => g.displayName)
            .join(' + ');
        return 'منطقتك كاملة: $names';
      case 'qatorah':
        return 'كل محافظات المملكة 🇯🇴';
      default:
        return governorate.displayName;
    }
  }
}