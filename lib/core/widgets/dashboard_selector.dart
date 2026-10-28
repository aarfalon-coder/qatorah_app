import 'package:flutter/material.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

import 'package:qatorah_app/screens/admin/admin_dashboard_screen.dart';
import 'package:qatorah_app/screens/auth/subscription_expired_screen.dart';
import 'package:qatorah_app/screens/customer/customer_home.dart';
import 'package:qatorah_app/screens/factory/factory_dashboard_screen.dart';
import 'package:qatorah_app/screens/parts_provider/parts_provider_dashboard.dart';
import 'package:qatorah_app/screens/provider/specialist_provider_dashboard.dart';
import 'package:qatorah_app/screens/provider_home.dart';
import 'package:qatorah_app/screens/station/station_dashboard.dart';
import 'package:qatorah_app/screens/tanker/tanker_home.dart';
import 'package:qatorah_app/screens/technician/technician_dashboard_screen.dart';

class DashboardSelector extends StatelessWidget {
  const DashboardSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // 1️⃣ فحص الاشتراك أولاً (باستثناء الأدمنز)
    if (AuthManager.isLoggedIn && !AuthManager.isSubscriptionActive) {
      if (AuthManager.adminLevel < AuthManager.levelViewer) {
        return const SubscriptionExpiredScreen();
      }
    }

    // 2️⃣ توجيه الأدمنز
    if (AuthManager.isSuperAdmin ||
        AuthManager.adminLevel >= AuthManager.levelViewer) {
      return const AdminDashboardScreen();
    }

    // 3️⃣ توجيه مزودي الخدمة والعملاء حسب الدور
    switch (AuthManager.role) {
      case UserRole.customer:
        return const CustomerHomeScreen();

      case UserRole.stationOwner:
        return const StationDashboard();

      case UserRole.factoryOwner:
        return const FactoryDashboardScreen();

      case UserRole.tankerDriver:
        return const TankerHomeScreen();

      case UserRole.distributionDriver:
        return SpecialistProviderDashboard(
          role: 'distribution_driver',
          userName: AuthManager.firstName,
        );

      case UserRole.stationTechnician:
      case UserRole.plumber:
      case UserRole.electrician:
        return const TechnicianDashboardScreen();

      case UserRole.partsProvider:
        return const PartsProviderDashboard();

      case UserRole.gasSupplier:
        return const ProviderHomeScreen();
    }
  }
}
