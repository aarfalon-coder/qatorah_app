import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_manager.dart'; // 🆕 لاستيراد بيانات المستخدم الحقيقي

class ProfileManager extends ChangeNotifier {
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;
  ProfileManager._internal() {
    _loadData();
  }

  // ═══ متغيرات بدون قيم وهمية ═══
  String _name = '';
  String _phone = '';
  String _email = '';
  String? _imagePath;

  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String? get imagePath => _imagePath;
  File? get imageFile => _imagePath != null ? File(_imagePath!) : null;

  // ═══ تحميل البيانات: محلياً أولاً، ثم من AuthManager ═══
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. محاولة قراءة البيانات المحفوظة محلياً (التي عدّلها المستخدم بنفسه)
    final savedName = prefs.getString('profile_name');
    final savedPhone = prefs.getString('profile_phone');
    final savedEmail = prefs.getString('profile_email');
    
    // 2. إذا وجدت بيانات محفوظة → استخدامها
    //    وإلا → استخدام بيانات المستخدم الحقيقي من AuthManager
    //    وإلا → نص فارغ (لا توجد قيم وهمية أبداً)
    _name = savedName ?? AuthManager.firstName;
    _phone = savedPhone ?? AuthManager.phone;
    _email = savedEmail ?? ''; // البريد غير متوفر في AuthManager حالياً، يُترك فارغاً
    
    _imagePath = prefs.getString('profile_image_path');
    
    notifyListeners();
  }

  // 🆕 مزامنة البيانات من AuthManager (يُستدعى عند تسجيل الدخول أو تحديث البيانات)
  Future<void> syncWithAuth() async {
    final prefs = await SharedPreferences.getInstance();
    
    // فقط إذا لم يكن المستخدم قد عدّل بياناته محلياً، نحدّثها من AuthManager
    if (prefs.getString('profile_name') == null) {
      _name = AuthManager.firstName;
    }
    if (prefs.getString('profile_phone') == null) {
      _phone = AuthManager.phone;
    }
    
    notifyListeners();
  }

  // ═══ حفظ البيانات (عندما يعدّل المستخدم ملفه الشخصي) ═══
  Future<void> saveProfile({
    required String name,
    required String phone,
    required String email,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _name = name;
    _phone = phone;
    _email = email;
    if (imagePath != null) _imagePath = imagePath;
    
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_phone', phone);
    await prefs.setString('profile_email', email);
    if (imagePath != null) {
      await prefs.setString('profile_image_path', imagePath);
    }
    notifyListeners();
  }

  // ═══ حذف الصورة الشخصية ═══
  Future<void> clearImage() async {
    _imagePath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    notifyListeners();
  }
}