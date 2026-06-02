import 'package:flutter/material.dart';

class CefrBadge extends StatelessWidget {
  final String? level;
  final String? label;
  final bool showLabel;

  const CefrBadge({
    super.key,
    required this.level,
    this.label,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (level == null) return const SizedBox.shrink();

    final color = _colorFor(level!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level!,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          if (showLabel && label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _colorFor(String level) => switch (level) {
    'A1' => const Color(0xFF4CAF50),
    'A2' => const Color(0xFF8BC34A),
    'B1' => const Color(0xFFFFC107),
    'B2' => const Color(0xFFFF9800),
    'C1' => const Color(0xFFF44336),
    'C2' => const Color(0xFF9C27B0),
    _    => const Color(0xFF9E9E9E),
  };
}