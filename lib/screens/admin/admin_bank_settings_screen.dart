import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class AdminBankSettingsScreen extends StatefulWidget {
  const AdminBankSettingsScreen({super.key});

  @override
  State<AdminBankSettingsScreen> createState() => _AdminBankSettingsScreenState();
}

class _AdminBankSettingsScreenState extends State<AdminBankSettingsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBankSettings();
  }

  Future<void> _loadBankSettings() async {
    try {
      final doc = await _db.collection('app_settings').doc('bank_info').get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _bankNameController.text = data['bankName'] ?? '';
          _accountNumberController.text = data['accountNumber'] ?? '';
          _beneficiaryNameController.text = data['beneficiaryName'] ?? '';
          _ibanController.text = data['iban'] ?? '';
          _whatsappController.text = data['whatsappNumber'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الإعدادات: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      await _db.collection('app_settings').doc('bank_info').set({
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'beneficiaryName': _beneficiaryNameController.text.trim(),
        'iban': _ibanController.text.trim(),
        'whatsappNumber': _whatsappController.text.trim().replaceAll('+', ''),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ إعدادات البنك بنجاح!'), backgroundColor: AppColors.refillGreen),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحفظ: $e'), backgroundColor: AppColors.plumberRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات التحويل البنكي', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFF0A0E1A),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.goldLight))
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'هذه البيانات ستظهر للعملاء في شاشة التحويل البنكي',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(_bankNameController, 'اسم البنك', Icons.account_balance),
                    const SizedBox(height: 16),
                    _buildTextField(_accountNumberController, 'رقم الحساب', Icons.numbers),
                    const SizedBox(height: 16),
                    _buildTextField(_beneficiaryNameController, 'اسم المستفيد', Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(_ibanController, 'رقم الآيبان (IBAN)', Icons.credit_card),
                    const SizedBox(height: 16),
                    _buildTextField(_whatsappController, 'رقم واتساب استقبال الإيصالات (بدون +)', Icons.message), // ✅ تم التصحيح هنا
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.refillGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('حفظ الإعدادات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.goldLight),
        filled: true,
        fillColor: const Color(0xFF1A1F2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.goldLight)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'يرجى إدخال $label';
        return null;
      },
    );
  }
}