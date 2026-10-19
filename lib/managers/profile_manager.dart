import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager extends ChangeNotifier {
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;
  ProfileManager._internal() {
    _loadData();
  }

  String _name = 'قاسم أبو البراء';
  String _phone = '0791234567';
  String _email = 'qasim@qatorah.jo';
  String? _imagePath;

  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String? get imagePath => _imagePath;
  File? get imageFile => _imagePath != null ? File(_imagePath!) : null;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? 'قاسم أبو البراء';
    _phone = prefs.getString('profile_phone') ?? '0791234567';
    _email = prefs.getString('profile_email') ?? 'qasim@qatorah.jo';
    _imagePath = prefs.getString('profile_image_path');
    notifyListeners();
  }

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

  Future<void> clearImage() async {
    _imagePath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    notifyListeners();
  }
}