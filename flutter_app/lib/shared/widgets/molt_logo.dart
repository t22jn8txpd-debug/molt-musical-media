import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

class MoltLogo extends StatelessWidget {
  const MoltLogo({super.key, this.size = 32, this.showFull = true});

  final double size;
  final bool showFull;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('🎵 ', style: TextStyle(fontSize: size * 0.8)),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [MoltColors.purple, MoltColors.pink],
          ).createShader(bounds),
          child: Text(
            showFull ? 'MOLT MUSICAL MEDIA' : 'MOLT',
            style: GoogleFonts.inter(
              fontSize: size,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
