import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _googleApiKey = 'AIzaSyA_fmDNM6K2ehAJWwyQxZYWfG0SJv_Ia0k';

  static Future<Position> getCurrentPosition() async {
    // 1. التحقق من تفعيل خدمات الموقع
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمات الموقع (GPS) معطلة. يرجى تفعيلها من إعدادات الهاتف.');
    }

    // 2. التحقق من الصلاحيات
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض صلاحية الموقع.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('صلاحية الموقع مرفوضة نهائياً. يرجى تفعيلها من إعدادات التطبيق.');
    }

    // 3. إجبار الهاتف على استخدام GPS الفعلي (أعلى دقة) وتجاهل آخر موقع محفوظ
    debugPrint('⏳ جاري طلب موقع دقيق من الـ GPS... (قد يأخذ 5-10 ثوانٍ)');
    
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // 4. طباعة دقة الموقع بالمتر (هذا هو المعيار الحقيقي للدقة)
    debugPrint('✅ تم الحصول على الإحداثيات.');
    debugPrint('📍 Lat: ${position.latitude}, Lng: ${position.longitude}');
    debugPrint('🎯 دقة الموقع (متر): ${position.accuracy} متر'); 
    // ملاحظة: إذا كان الرقم أقل من 50، فالموقع دقيق جداً. إذا كان فوق 1000، فهاتفك يستخدم أبراج الاتصال.

    return position;
  }

  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_googleApiKey&language=ar',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final components = List<Map<String, dynamic>>.from(result['address_components'] ?? []);
          
          String street = '';
          String neighborhood = '';
          String city = '';
          
          for (var comp in components) {
            final types = List<String>.from(comp['types'] ?? []);
            final name = comp['long_name'] ?? '';
            
            if (types.contains('route') && street.isEmpty) street = name;
            if ((types.contains('sublocality') || types.contains('neighborhood') || types.contains('sublocality_level_1')) && neighborhood.isEmpty) {
              neighborhood = name;
            }
            if (types.contains('locality') && city.isEmpty) city = name;
            if (types.contains('administrative_area_level_1') && city.isEmpty) city = name;
          }
          
          final parts = <String>[];
          if (street.isNotEmpty) parts.add(street);
          if (neighborhood.isNotEmpty && neighborhood != city) parts.add(neighborhood);
          if (city.isNotEmpty) parts.add(city);
          
          final address = parts.isNotEmpty ? parts.join('، ') : 'موقع محدد';
          
          debugPrint('🏠 العنوان من جوجل: $address');
          return address;
        } else {
          debugPrint('⚠️ حالة API: ${data['status']}');
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب العنوان: $e');
    }
    return 'موقع محدد على الخريطة';
  }
}