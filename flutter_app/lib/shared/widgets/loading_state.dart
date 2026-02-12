import 'package:flutter/material.dart';
import '../../app/theme.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: MoltColors.purple,
              strokeWidth: 3,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 18),
            Text(
              label!,
              style: TextStyle(color: MoltColors.textMuted, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
