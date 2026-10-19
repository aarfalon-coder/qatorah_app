class PaymentMethodModel {
  final String id;
  final String type; // 'cash', 'wallet', 'card'
  final String title;
  final String subtitle;
  final String icon;
  final bool isEnabled;
  final bool isDefault;
  final Map<String, dynamic>? details;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isEnabled = true,
    this.isDefault = false,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
      'isEnabled': isEnabled,
      'isDefault': isDefault,
      'details': details,
    };
  }

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'wallet',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      icon: map['icon'] ?? 'wallet',
      isEnabled: map['isEnabled'] ?? true,
      isDefault: map['isDefault'] ?? false,
      details: map['details'],
    );
  }

  static List<PaymentMethodModel> getDefaultMethods() {
    return [
      PaymentMethodModel(
        id: 'wallet',
        type: 'wallet',
        title: 'محفظة قطوره',
        subtitle: 'خصم فوري من الرصيد + نقاط مكافأة',
        icon: 'account_balance_wallet',
        isEnabled: true,
        isDefault: true,
      ),
      PaymentMethodModel(
        id: 'cash',
        type: 'cash',
        title: 'الدفع نقداً',
        subtitle: 'ادفع للسائق عند الاستلام',
        icon: 'payments',
        isEnabled: true,
      ),
      PaymentMethodModel(
        id: 'card',
        type: 'card',
        title: 'بطاقة ائتمان',
        subtitle: 'Visa / Mastercard - قريباً',
        icon: 'credit_card',
        isEnabled: false,
      ),
    ];
  }
}