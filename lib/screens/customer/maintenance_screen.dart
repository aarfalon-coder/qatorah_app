import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/technician_model.dart';
import 'package:qatorah_app/services/ai_maintenance_service.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _messageController = TextEditingController();
  final _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();

  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  bool _isListening = false;
  bool _isChatListening = false;
  String? _aiResponse;
  String? _selectedTechnicianId;
  final List<Map<String, String>> _chatHistory = [];
  List<TechnicianModel> _availableTechnicians = [];
  bool _isLoadingTechnicians = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableTechnicians();
    _initSpeech();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onError: (error) =>
          _showSnackBar('خطأ في الميكروفون: $error', Colors.red),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _isChatListening = false;
          });
        }
      },
    );
  }

  Future<void> _startListening({bool forChat = false}) async {
    if (!_speech.isAvailable) {
      _showSnackBar('الميكروفون غير متاح', Colors.orange);
      return;
    }

    if (forChat) {
      setState(() => _isChatListening = true);
    } else {
      setState(() => _isListening = true);
    }

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          if (forChat) {
            _messageController.text = result.recognizedWords;
          } else {
            _descriptionController.text = result.recognizedWords;
          }
        });
      },
      listenOptions: stt.SpeechListenOptions(localeId: 'ar_JO'),
    );
  }

  Future<void> _stopListening({bool forChat = false}) async {
    await _speech.stop();
    setState(() {
      if (forChat) {
        _isChatListening = false;
      } else {
        _isListening = false;
      }
    });
  }

  Future<void> _loadAvailableTechnicians() async {
    setState(() => _isLoadingTechnicians = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('technicians')
          .where('is_suspended', isEqualTo: false)
          .where('is_available', isEqualTo: true)
          .where('active_requests_count', isLessThan: 2)
          .orderBy('rating', descending: true)
          .get();
      setState(() {
        _availableTechnicians = snapshot.docs
            .map((doc) => TechnicianModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      setState(() => _availableTechnicians = []);
    } finally {
      setState(() => _isLoadingTechnicians = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      await _analyzeWithAI();
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_selectedImage == null && _descriptionController.text.isEmpty) {
      _showSnackBar('يرجى تصوير العطل أو كتابة وصف للمشكلة', Colors.orange);
      return;
    }
    setState(() {
      _isAnalyzing = true;
      _aiResponse = null;
    });
    try {
      final response = await AIMaintenanceService.analyzeMaintenanceIssue(
        imageFile: _selectedImage,
        textDescription: _descriptionController.text.isEmpty
            ? 'يرجى تحليل الصورة'
            : _descriptionController.text,
      );
      setState(() {
        _aiResponse = response;
        _chatHistory.add({
          'role': 'user',
          'content': _descriptionController.text.isEmpty
              ? 'صورة مرفقة للتحليل'
              : _descriptionController.text,
        });
        _chatHistory.add({'role': 'ai', 'content': response});
      });
      if (response.contains('عذراً') && response.contains('مختص')) {
        _showSnackBar(
            'الذكاء الاصطناعي لا يمكنه تحليل هذه الصورة', Colors.orange);
      }
    } catch (e) {
      setState(() => _aiResponse = 'حدث خطأ في التحليل: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _sendMessageToAI() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _chatHistory.add({'role': 'user', 'content': message});
      _messageController.clear();
      _isAnalyzing = true;
    });
    try {
      final response = await AIMaintenanceService.analyzeMaintenanceIssue(
        imageFile: _selectedImage,
        textDescription: message,
      );
      setState(() {
        _chatHistory.add({'role': 'ai', 'content': response});
        _aiResponse = response;
      });
    } catch (e) {
      setState(() {
        _chatHistory
            .add({'role': 'ai', 'content': 'عذراً، حدث خطأ في الاتصال'});
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTechnicianId == null) {
      _showSnackBar('يرجى اختيار فني للصيانة', Colors.red);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('maintenance/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('maintenance_requests').add({
        'customer_id': AuthManager.firebaseUid ?? '',
        'technician_id': _selectedTechnicianId,
        'images': imageUrl != null ? [imageUrl] : [],
        'text_description': _descriptionController.text,
        'ai_chat_history': _chatHistory,
        'ai_final_diagnosis': _aiResponse,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
      _showSnackBar('تم إرسال طلب الصيانة بنجاح!', AppColors.refillGreen);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('فشل إرسال الطلب: $e', Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.goldLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'الصيانة الذكية',
          style: TextStyle(
            color: AppColors.goldLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('صور العطل', Icons.camera_alt, isDark),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.goldLight.withValues(alpha: 0.3)),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt,
                              size: 60, color: AppColors.goldLight),
                          const SizedBox(height: 12),
                          Text(
                            'اضغط لتصوير العطل',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(
                'وصف المشكلة (إجباري)', Icons.description, isDark),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'اشرح المشكلة أو اضغط على الميكروفون...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1A1F2E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.goldLight.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.goldLight.withValues(alpha: 0.3)),
                      ),
                    ),
                    maxLines: 3,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى كتابة أو تسجيل وصف للمشكلة';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isListening
                      ? () => _stopListening(forChat: false)
                      : () => _startListening(forChat: false),
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? AppColors.plumberRed
                        : AppColors.refillGreen,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isListening
                        ? AppColors.plumberRed.withValues(alpha: 0.2)
                        : (isDark ? const Color(0xFF1A1F2E) : Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  tooltip: _isListening ? 'إيقاف التسجيل' : 'تحدث لكتابة الوصف',
                ),
              ],
            ),
            if (_isListening)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.refillGreen),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'جاري الاستماع... تحدث الآن',
                      style: TextStyle(
                          color: AppColors.refillGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildSectionTitle(
                'محادثة الذكاء الاصطناعي', Icons.psychology, isDark),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.crystalBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.crystalBlue.withValues(alpha: 0.3)),
              ),
              child: _chatHistory.isEmpty
                  ? Center(
                      child: Text(
                        'صور العطل أو اكتب وصفك ليبدأ التحليل...',
                        style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _chatHistory.length,
                      itemBuilder: (context, index) {
                        final msg = _chatHistory[index];
                        final isUser = msg['role'] == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.goldLight
                                  : AppColors.refillGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['content'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اسأل الذكاء الاصطناعي...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1A1F2E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    onSubmitted: (_) => _sendMessageToAI(),
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ ميكروفون أخضر للذكاء الاصطناعي
                IconButton(
                  onPressed: _isChatListening
                      ? () => _stopListening(forChat: true)
                      : () => _startListening(forChat: true),
                  icon: Icon(
                    _isChatListening ? Icons.mic : Icons.mic_none,
                    color: _isChatListening
                        ? AppColors.plumberRed
                        : AppColors.refillGreen,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isChatListening
                        ? AppColors.plumberRed.withValues(alpha: 0.2)
                        : AppColors.refillGreen.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  tooltip: _isChatListening
                      ? 'إيقاف التسجيل'
                      : 'تحدث لسؤال الذكاء الاصطناعي',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isAnalyzing ? null : _sendMessageToAI,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.goldLight))
                      : const Icon(Icons.send, color: AppColors.goldLight),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? const Color(0xFF1A1F2E) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('اختر الفني', Icons.engineering, isDark),
            const SizedBox(height: 12),
            if (_isLoadingTechnicians)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.goldLight))
            else if (_availableTechnicians.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لا يوجد فنيين متاحين حالياً. يرجى المحاولة لاحقاً أو التواصل مع الدعم.',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableTechnicians.length,
                itemBuilder: (context, index) {
                  final tech = _availableTechnicians[index];
                  final isSelected = _selectedTechnicianId == tech.id;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedTechnicianId = tech.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.goldLight.withValues(alpha: 0.2)
                            : (isDark ? const Color(0xFF1A1F2E) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.goldLight
                              : AppColors.goldLight.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  tech.specialty.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(tech.specialty.icon,
                                color: tech.specialty.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tech.name,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 14, color: AppColors.goldLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${tech.rating} (${tech.reviewCount} تقييم)',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 14, color: AppColors.crystalBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      tech.nextAvailableTime,
                                      style: const TextStyle(
                                        color: AppColors.crystalBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color:
                                isSelected ? AppColors.goldLight : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.refillGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'إرسال طلب الصيانة',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldLight, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
