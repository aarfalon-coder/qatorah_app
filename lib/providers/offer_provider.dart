import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/offer_model.dart';

class OfferProvider extends ChangeNotifier {
  List<OfferModel> _allOffers = [];
  List<OfferModel> _activeOffers = [];
  List<OfferModel> _myOffers = [];
  
  String _searchQuery = '';
  String _selectedServiceType = 'all';
  
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  List<OfferModel> get allOffers => List.unmodifiable(_allOffers);
  List<OfferModel> get activeOffers => List.unmodifiable(_activeOffers);
  List<OfferModel> get myOffers => List.unmodifiable(_myOffers);
  
  String get searchQuery => _searchQuery;
  String get selectedServiceType => _selectedServiceType;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get activeCount => _activeOffers.length;
  int get totalCount => _allOffers.length;

  // ═══ تعيين العروض ═══
  void setOffers(List<OfferModel> offers) {
    _allOffers = offers;
    _activeOffers = offers.where((o) => o.isCurrentlyActive).toList();
    _applyFilters();
  }

  // ═══ تعيين عروض المزود ═══
  void setMyOffers(List<OfferModel> offers, String providerId) {
    _myOffers = offers.where((o) => o.providerId == providerId).toList();
    notifyListeners();
  }

  // ═══ البحث ═══
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // ═══ فلترة حسب نوع الخدمة ═══
  void filterByServiceType(String serviceType) {
    _selectedServiceType = serviceType;
    _applyFilters();
  }

  // ═══ تطبيق الفلاتر ═══
  void _applyFilters() {
    var offers = _allOffers.where((offer) {
      // فلترة البحث
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!offer.title.toLowerCase().contains(query) &&
            !offer.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // فلترة نوع الخدمة
      if (_selectedServiceType != 'all') {
        if (offer.serviceType != _selectedServiceType &&
            offer.serviceType != 'all') {
          return false;
        }
      }

      return true;
    }).toList();

    _activeOffers = offers.where((o) => o.isCurrentlyActive).toList();
    notifyListeners();
  }

  // ═══ إضافة عرض ═══
  void addOffer(OfferModel offer) {
    _allOffers.insert(0, offer);
    if (offer.isCurrentlyActive) {
      _activeOffers.insert(0, offer);
    }
    notifyListeners();
  }

  // ═══ تحديث عرض ═══
  void updateOffer(OfferModel updatedOffer) {
    final index = _allOffers.indexWhere((o) => o.id == updatedOffer.id);
    if (index == -1) return;

    _allOffers[index] = updatedOffer;
    _applyFilters();
  }

  // ═══ حذف عرض ═══
  void deleteOffer(String offerId) {
    _allOffers.removeWhere((o) => o.id == offerId);
    _activeOffers.removeWhere((o) => o.id == offerId);
    _myOffers.removeWhere((o) => o.id == offerId);
    notifyListeners();
  }

  // ═══ تفعيل / تعطيل عرض ═══
  void toggleOffer(String offerId) {
    final index = _allOffers.indexWhere((o) => o.id == offerId);
    if (index == -1) return;

    final old = _allOffers[index];
    _allOffers[index] = old.copyWith(isActive: !old.isActive);
    _applyFilters();
  }

  // ═══ حساب الخصم ═══
  double calculateDiscount(OfferModel offer, double orderAmount) {
    // التحقق من الحد الأدنى
    if (offer.minOrderAmount != null && orderAmount < offer.minOrderAmount!) {
      return 0.0;
    }

    double discount = 0.0;
    if (offer.discountType == 'percentage') {
      discount = orderAmount * (offer.discountValue / 100);
    } else {
      discount = offer.discountValue;
    }

    // التحقق من الحد الأقصى
    if (offer.maxDiscount != null && discount > offer.maxDiscount!) {
      discount = offer.maxDiscount!;
    }

    // التأكد إنه الخصم ما يتجاوز قيمة الطلب
    if (discount > orderAmount) {
      discount = orderAmount;
    }

    return discount;
  }

  // ═══ تحميل العروض ═══
  Future<void> loadOffers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // سيتم ربطه بـ Firestore لاحقاً
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل العروض: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══ إعادة تعيين ═══
  void reset() {
    _allOffers = [];
    _activeOffers = [];
    _myOffers = [];
    _searchQuery = '';
    _selectedServiceType = 'all';
    _errorMessage = null;
    notifyListeners();
  }
}