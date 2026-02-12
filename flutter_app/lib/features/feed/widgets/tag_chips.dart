import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class TagChips extends StatelessWidget {
  const TagChips({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: MoltColors.purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MoltColors.purple.withValues(alpha: 0.25)),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: MoltColors.purple.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
