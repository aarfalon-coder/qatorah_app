import 'package:flutter/material.dart';

class EmojiFeedbackWidget extends StatelessWidget {
  final int selectedEmoji;
  final Function(int) onSelected;

  const EmojiFeedbackWidget({
    super.key,
    required this.selectedEmoji,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> _emojis = const [
    {'emoji': '😞', 'label': 'سيء', 'value': 1},
    {'emoji': '😐', 'label': 'مقبول', 'value': 2},
    {'emoji': '🙂', 'label': 'جيد', 'value': 3},
    {'emoji': '😊', 'label': 'ممتاز', 'value': 4},
    {'emoji': '🤩', 'label': 'رائع', 'value': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _emojis.map((item) {
        final isSelected = selectedEmoji == item['value'];
        return GestureDetector(
          onTap: () => onSelected(item['value']),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  item['emoji'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}