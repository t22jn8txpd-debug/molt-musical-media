import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: MoltColors.purplePinkGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: MoltColors.purple.withValues(alpha: 0.4), blurRadius: 30),
                  ],
                ),
                child: const Center(
                  child: Text('🎹', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
                child: Text(
                  'Beat Maker Studio',
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Multi-genre beat creation with a professional sequencer, '
                'synths, and samples. Hip Hop, Trap, R&B, Pop, Rock, Country, EDM and more.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 240,
                child: GradientButton(
                  label: '🔥 Coming Soon',
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
