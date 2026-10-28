import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIMaintenanceService {
  // flutter run --dart-define=GEMINI_API_KEY=your_key
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  static Future<String> analyzeMaintenanceIssue({
    required File? imageFile,
    required String textDescription,
  }) async {
    if (_apiKey.isEmpty) {
      return "الذكاء الاصطناعي غير مُهيأ: مفتاح GEMINI_API_KEY غير موجود.";
    }
    try {
      final prompt = TextPart('''
أنت "مساعد قطوره الذكي"، مختص حصراً بصيانة الفلاتر، المحطات المائية، والأعطال المنزلية المتعلقة بالمياه والسباكة.

المهمة:
1. حلل الصورة المرفقة (إن وجدت) والوصف النصي التالي: "$textDescription".
2. إذا كانت الصورة لا علاقة لها بالصيانة، اعتذر وقل: "عذراً، أنا مختص فقط بصيانة الفلاتر والمياه."
3. إذا كانت المشكلة متعلقة بالمياه، قدم التشخيص وقطع الغيار والتكلفة بالدينار الأردني.
4. كن مختصراً ومهنياً بالعربية.
      ''');

      final List<Part> parts = [prompt];

      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final content = [Content.multi(parts)];
      final response = await _model.generateContent(content);
      return response.text ?? "عذراً، لم أتمكن من تحليل الطلب.";
      
    } catch (e) {
      return "حدث خطأ في الذكاء الاصطناعي: $e";
    }
  }
}