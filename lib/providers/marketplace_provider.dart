import 'package:flutter/foundation.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/technician_model.dart';

class MarketplaceProvider extends ChangeNotifier {
  List<AdvertisementModel> _allAds = [];
  List<AdvertisementModel> _filteredAds = [];
  List<TechnicianModel> _technicians = [];
  List<TechnicianModel> _filteredTechnicians = [];
  
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedRegion = 'all';
  String _sortBy = 'latest';
  
  bool _isLoading = false;
  String? _errorMessage;

  // ═══ Getters ═══
  List<AdvertisementModel> get allAds => List.unmodifiable(_allAds);
  List<AdvertisementModel> get filteredAds => List.unmodifiable(_filteredAds);
  List<TechnicianModel> get technicians => List.unmodifiable(_technicians);
  List<TechnicianModel> get filteredTechnicians => List.unmodifiable(_filteredTechnicians);
  
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedRegion => _selectedRegion;
  String get sortBy => _sortBy;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get adsCount => _filteredAds.length;
  int get techCount => _filteredTechnicians.length;

  // ═══ تعيين الإعلانات ═══
  void setAds(List<AdvertisementModel> ads) {
    _allAds = ads;
    _applyFilters();
  }

  // ═══ تعيين الفنيين ═══
  void setTechnicians(List<TechnicianModel> techs) {
    _technicians = techs;
    _applyFilters();
  }

  // ═══ البحث ═══
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // ═══ فلترة حسب الفئة ═══
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // ═══ فلترة حسب المنطقة ═══
  void filterByRegion(String region) {
    _selectedRegion = region;
    _applyFilters();
  }

  // ═══ الترتيب ═══
  void sortByOption(String option) {
    _sortBy = option;
    _applyFilters();
  }

  // ═══ تطبيق الفلاتر ═══
  void _applyFilters() {
    var ads = _allAds.where((ad) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!ad.title.toLowerCase().contains(query) &&
            !ad.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      if (_selectedCategory != 'all') {
        if (ad.category.code != _selectedCategory) return false;
      }

      if (_selectedRegion != 'all') {
        if (!ad.coverage.contains(_selectedRegion)) return false;
      }

      return true;
    }).toList();

    switch (_sortBy) {
      case 'price_low':
        ads.sort((a, b) => a.pricing.amount.compareTo(b.pricing.amount));
        break;
      case 'price_high':
        ads.sort((a, b) => b.pricing.amount.compareTo(a.pricing.amount));
        break;
      case 'rating':
        ads.sort((a, b) =>
            b.publisher.userRating.compareTo(a.publisher.userRating));
        break;
      default:
        ads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _filteredAds = ads;

    var techs = _technicians.where((t) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!t.name.toLowerCase().contains(query) &&
            !t.specialty.arabicName.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    _filteredTechnicians = techs;

    notifyListeners();
  }

  // ═══ إعادة تعيين الفلاتر ═══
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'all';
    _selectedRegion = 'all';
    _sortBy = 'latest';
    _applyFilters();
  }

  // ═══ تحميل البيانات ═══
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تحميل البيانات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══ مسح الأخطاء ═══
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}