import 'package:flutter/foundation.dart';
import 'package:weather/weather.dart';

class WeatherService {
  static const String apiKey = 'db0f73ca3ed9b8fd1aee87f820fe6fa8'; 
  
  static Future<Weather?> getCurrentWeather(double lat, double lon) async {
    try {
      debugPrint('️ جاري جلب الطقس للإحداثيات: $lat, $lon');
      
      WeatherFactory wf = WeatherFactory(apiKey, language: Language.ARABIC);
      Weather weather = await wf.currentWeatherByLocation(lat, lon);

      debugPrint('✅ الطقس تم جلبه بنجاح:');
      debugPrint('   درجة الحرارة: ${weather.temperature?.celsius}°C');
      debugPrint('   الوصف: ${weather.weatherDescription}');
      debugPrint('   الرطوبة: ${weather.humidity}%');
      debugPrint('   الرياح: ${weather.windSpeed} كم/س');

      return weather;
    } catch (e, stackTrace) {
      debugPrint('❌ خطأ فادح في جلب الطقس: $e');
      debugPrint(' التفاصيل: $stackTrace');
      return null;
    }
  }
}