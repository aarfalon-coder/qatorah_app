import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_colors.dart';
import 'package:qatorah_app/managers/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  bool _glassEnabled = ThemeManager.glassEnabled;
  double _bgOpacity = ThemeManager.bgOpacity;
  String _fontSize = 'متوسط';
  bool _notificationsEnabled = true;
  bool _statsEnabled = true;
  String _selectedLanguage = 'العربية';
  Color _selectedAccent = AppColors.crystalBlue;

  final List<Color> _accentColors = [
    AppColors.crystalBlue,
    AppColors.waterBlue,
    AppColors.tankCyan,
    AppColors.refillGreen,
    AppColors.goldLight,
    AppColors.maintenanceOrange,
    AppColors.plumberRed,
    AppColors.factoryPurple,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getString('font_size') ?? 'متوسط';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _statsEnabled = prefs.getBool('stats_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'العربية';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تحديد الألوان ديناميكياً بناءً على الوضع الليلي أو النهاري
    final isDark = ThemeManager.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2029);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor, // ✅ الخلفية تتغير الآن
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('تخصيص التطبيق',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ 1. الألوان ═══
            Text('🎨 لون التطبيق الرئيسي',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor, // ✅ البطاقة تتغير
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _accentColors.map((color) {
                  final isSelected = _selectedAccent == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAccent = color);
                      ThemeManager.setAccentColor(color);
                      _saveSetting(
                          'accent_color_index', _accentColors.indexOf(color));
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF1A2029))
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ═══ 2. الوضع الليلي/النهاري ═══
            Text('🌙 الوضع الليلي / النهاري',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildToggleCard(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              title: isDark ? 'الوضع الليلي' : 'الوضع النهاري',
              subtitle: isDark
                  ? 'تقليل إجهاد العين في الإضاءة المنخفضة'
                  : 'واجهة فاتحة ومريحة للعين',
              value: isDark,
              color: AppColors.goldLight,
              textColor: textColor,
              subTextColor: subTextColor,
              cardColor: cardColor,
              onChanged: (val) {
                setState(() {});
                ThemeManager.toggleTheme(val);
              },
            ),
            const SizedBox(height: 24),

            // ═══ 3. تأثير الزجاج ═══
            Text('🔲 تأثير الزجاج (Glass)',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('تفعيل تأثير الزجاج',
                        style: TextStyle(color: textColor)),
                    subtitle: Text('شفافية: ${(_bgOpacity * 100).toInt()}%',
                        style: TextStyle(color: subTextColor)),
                    value: _glassEnabled,
                    activeThumbColor: AppColors.goldLight,
                    onChanged: (val) {
                      setState(() => _glassEnabled = val);
                      ThemeManager.setGlassEnabled(val);
                      _saveSetting('glass_enabled', val);
                    },
                  ),
                  if (_glassEnabled)
                    Slider(
                      value: _bgOpacity,
                      min: 0.3,
                      max: 1.0,
                      divisions: 7,
                      activeColor: AppColors.goldLight,
                      inactiveColor: subTextColor,
                      label: '${(_bgOpacity * 100).toInt()}%',
                      onChanged: (val) {
                        setState(() => _bgOpacity = val);
                        ThemeManager.setBgOpacity(val);
                        _saveSetting('bg_opacity', val);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ═══ 4. حجم الخط ═══
            Text('🔤 حجم الخط',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['صغير', 'متوسط', 'كبير'].map((size) {
                  final isSelected = _fontSize == size;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _fontSize = size);
                        _saveSetting('font_size', size);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.goldLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          size,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF0A0E1A)
                                : subTextColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ═══ 5. اللغة ═══
            Text('🌍 اللغة',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: _buildLanguageButton(
                          'العربية', '🇯🇴', textColor, subTextColor)),
                  Expanded(
                      child: _buildLanguageButton(
                          'English', '🇬🇧', textColor, subTextColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ═══ 6. الإشعارات ═══
            Text('🔔 الإشعارات',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildToggleCard(
              icon: Icons.notifications,
              title: 'تفعيل الإشعارات',
              subtitle: 'استلام تنبيهات الطلبات والعروض',
              value: _notificationsEnabled,
              color: AppColors.refillGreen,
              textColor: textColor,
              subTextColor: subTextColor,
              cardColor: cardColor,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                _saveSetting('notifications_enabled', val);
              },
            ),
            const SizedBox(height: 24),

            // ═══ 7. الإحصائيات ═══
            Text('📊 الإحصائيات',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildToggleCard(
              icon: Icons.bar_chart,
              title: 'إظهار الإحصائيات',
              subtitle: 'عرض الرسوم البيانية في لوحة التحكم',
              value: _statsEnabled,
              color: AppColors.factoryPurple,
              textColor: textColor,
              subTextColor: subTextColor,
              cardColor: cardColor,
              onChanged: (val) {
                setState(() => _statsEnabled = val);
                _saveSetting('stats_enabled', val);
              },
            ),
            const SizedBox(height: 24),

            // ═══ زر إعادة الضبط ═══
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _resetToDefaults(),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة الإعدادات الافتراضية'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.plumberRed,
                  side: const BorderSide(color: AppColors.plumberRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Color textColor,
    required Color subTextColor,
    required Color cardColor,
    ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        subtitle:
            Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 11)),
        value: value,
        activeThumbColor: color,
        onChanged: onChanged ?? (val) {},
      ),
    );
  }

  Widget _buildLanguageButton(
      String lang, String flag, Color textColor, Color subTextColor) {
    final isSelected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLanguage = lang);
        _saveSetting('selected_language', lang);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              lang,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0A0E1A) : subTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    setState(() {
      _glassEnabled = true;
      _bgOpacity = 0.85;
      _fontSize = 'متوسط';
      _notificationsEnabled = true;
      _statsEnabled = true;
      _selectedLanguage = 'العربية';
      _selectedAccent = AppColors.crystalBlue;
    });
    ThemeManager.setGlassEnabled(true);
    ThemeManager.setBgOpacity(0.85);
    ThemeManager.setAccentColor(AppColors.crystalBlue);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة الإعدادات الافتراضية'),
        backgroundColor: AppColors.crystalBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
