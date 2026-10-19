class AppRoutes {
  // ═══ شاشات البداية ═══
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String roleSelection = '/role-selection';

  // ═══ المصادقة ═══
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String providerRegister = '/provider-register';

  // ═══ العميل ═══
  static const String customerHome = '/customer/home';
  static const String customerId = '/customer/id';
  static const String customerQr = '/customer/qr';
  static const String customerMap = '/customer/map';
  static const String customerReview = '/customer/review';
  static const String cart = '/customer/cart';
  static const String checkout = '/customer/checkout';
  static const String orderConfirmation = '/customer/order-confirmation';
  static const String myCoupons = '/customer/coupons';
  static const String myReviews = '/customer/reviews';
  static const String wallet = '/customer/wallet';
  static const String paymentHistory = '/customer/payment-history';
  static const String paymentMethod = '/customer/payment-method';
  static const String referral = '/customer/referral';
  static const String subscriptions = '/customer/subscriptions';
  static const String support = '/customer/support';
  static const String terms = '/customer/terms';
  static const String about = '/customer/about';
  static const String appReview = '/customer/app-review';

  // ═══ الخدمات ═══
  static const String drinkingWater = '/services/drinking-water';
  static const String gas = '/services/gas';
  static const String tank = '/services/tank';
  static const String tankOrder = '/services/tank-order';
  static const String homeRefill = '/services/home-refill';
  static const String waterOrder = '/services/water-order';
  static const String maintenance = '/services/maintenance';
  static const String maintenanceRequest = '/services/maintenance-request';
  static const String tankerRequest = '/services/tanker-request';
  static const String calculator = '/services/calculator';
  static const String supplierSelection = '/services/supplier-selection';
  static const String offers = '/services/offers';

  // ═══ السوق ═══
  static const String marketplace = '/marketplace';
  static const String marketplaceHome = '/marketplace/home';
  static const String adDetails = '/marketplace/ad-details';
  static const String addMachineListing = '/marketplace/add-listing';
  static const String machineDetails = '/marketplace/machine-details';
  static const String techniciansList = '/marketplace/technicians';
  static const String technicianProfile = '/marketplace/technician-profile';
  static const String partsStore = '/marketplace/parts';
  static const String filtersMarketplace = '/marketplace/filters';

  // ═══ المزود ═══
  static const String providerHome = '/provider/home';
  static const String providerType = '/provider/type';
  static const String providerOrders = '/provider/orders';
  static const String providerStats = '/provider/stats';
  static const String providerProfile = '/provider/profile';
  static const String providerWallet = '/provider/wallet';
  static const String providerReview = '/provider/review';
  static const String providerNotifications = '/provider/notifications';
  static const String providerChangePassword = '/provider/change-password';
  static const String createAd = '/provider/create-ad';
  static const String myAds = '/provider/my-ads';
  static const String adStats = '/provider/ad-stats';
  static const String qrTools = '/provider/qr-tools';
  static const String qrScanner = '/provider/qr-scanner';

  // ═══ السائق ═══
  static const String driverHome = '/driver/home';
  static const String deliveryRequests = '/driver/delivery-requests';
  static const String driverEarnings = '/driver/earnings';

  // ═══ المحطة ═══
  static const String stationDashboard = '/station/dashboard';
  static const String stationIncomingOrders = '/station/incoming-orders';
  static const String stationPrices = '/station/prices';
  static const String stationDrivers = '/station/drivers';
  static const String stationAccounting = '/station/accounting';
  static const String stationMaintenance = '/station/maintenance';
  static const String stationQrScanner = '/station/qr-scanner';

  // ═══ التنك ═══
  static const String tankerHome = '/tanker/home';
  static const String tankerSettings = '/tanker/settings';

  // ═══ السوبر أدمن ═══
  static const String adminDashboard = '/admin/dashboard';

  // ═══ الإعدادات ═══
  static const String customize = '/settings/customize';
  static const String profileSettings = '/settings/profile';

  // ═══ QR العام ═══
  static const String qrScannerMain = '/qr-scanner';
  static const String accountStatement = '/account-statement';

  // ═══ Placeholder ═══
  static const String placeholder = '/placeholder';
  static const String reviewSuccess = '/review-success';
}