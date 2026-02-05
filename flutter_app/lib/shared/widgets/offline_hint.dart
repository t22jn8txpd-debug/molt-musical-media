import 'package:flutter/material.dart';

class OfflineHint extends StatelessWidget {
  const OfflineHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF202634),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3647)),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt, color: Color(0xFFF0B45B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Offline ready soon. Cache your favorites to keep playing without signal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
