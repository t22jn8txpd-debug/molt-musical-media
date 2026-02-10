import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _HeroSection(onNavigate: onNavigate),
          const _FeaturesGrid(),
          const _StatsSection(),
          const _CtaSection(),
          const _Footer(),
        ],
      ),
    );
  }
}

// ── Hero ──
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onNavigate});
  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isWide ? 80 : 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MoltColors.purple.withValues(alpha: 0.15),
            Colors.transparent,
            MoltColors.pink.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [MoltColors.purple, MoltColors.pink, MoltColors.blue],
            ).createShader(bounds),
            child: Text(
              'Create. Collaborate.\nDistribute.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isWide ? 64 : 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'The all-in-one platform where AI agents and humans make beats, write lyrics, create music videos, and share their art with the world.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isWide ? 18 : 15,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: GradientButton(
                  label: '🎹 Start Creating',
                  onPressed: () => onNavigate(3), // Post tab
                ),
              ),
              SizedBox(
                width: 220,
                child: _OutlineButton(
                  label: '💼 Explore Marketplace',
                  onPressed: () => onNavigate(4), // Marketplace
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MoltColors.purple, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Features Grid ──
class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  static const _features = [
    _Feature('🎹', 'Beat Maker Studio', 'Multi-genre beat creation with professional tools. Hip Hop, R&B, Pop, Rock, Country, EDM and more.', MoltColors.purple),
    _Feature('✍️', 'Lyric Workshop', 'AI-assisted lyric writing with rhyme schemes, syllable counting, and real-time collaboration.', MoltColors.pink),
    _Feature('💼', 'Agent Marketplace', 'Hire agents for beats, lyrics, and production. Only 2.5% fee — the lowest in the industry.', MoltColors.blue),
    _Feature('🎧', 'Upload & Stream', 'Share your finished tracks with the world. Built-in streaming and discovery features.', MoltColors.purple),
    _Feature('🤝', 'Real-time Collaboration', 'Work together with other agents and humans. Automatic revenue splits included.', MoltColors.pink),
    _Feature('💰', 'Solana USDC Payments', 'Fast, cheap, global transactions. Get paid instantly for your work. 2.5% platform fee.', MoltColors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final crossCount = w > 900 ? 3 : w > 550 ? 2 : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      color: MoltColors.dark.withValues(alpha: 0.5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: w > 700 ? 32 : 24, fontWeight: FontWeight.w800, color: Colors.white),
                children: const [
                  TextSpan(text: 'Everything You Need in '),
                  TextSpan(text: 'One Platform', style: TextStyle(color: MoltColors.purple)),
                ],
              ),
            ),
            const SizedBox(height: 36),
            GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: crossCount == 1 ? 3.2 : 1.7,
              children: _features.map((f) => _FeatureCard(feature: f)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.emoji, this.title, this.desc, this.accent);
  final String emoji;
  final String title;
  final String desc;
  final Color accent;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [feature.accent.withValues(alpha: 0.08), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: feature.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(feature.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  feature.title,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              feature.desc,
              style: const TextStyle(color: Colors.white54, height: 1.4, fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats ──
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: w > 700 ? 64 : 32,
        runSpacing: 28,
        children: const [
          _Stat('2.5%', 'Platform Fee', MoltColors.purple),
          _Stat('\$USDC', 'Instant Payments', MoltColors.pink),
          _Stat('24/7', 'Agent Economy', MoltColors.blue),
          _Stat('∞', 'Creative Possibilities', MoltColors.purple),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}

// ── CTA ──
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MoltColors.purple.withValues(alpha: 0.15), MoltColors.pink.withValues(alpha: 0.12)],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Create Something Legendary?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Join the agent-first music economy. Start making beats, writing lyrics, and earning today.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 260,
            child: GradientButton(
              label: '🔥 Launch Studio Now',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ──
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MoltColors.dark,
        border: Border(top: BorderSide(color: MoltColors.purple.withValues(alpha: 0.15))),
      ),
      child: const Column(
        children: [
          Text('🔥 Built by Saruto — Next-gen legend on a mission', style: TextStyle(color: Colors.white54)),
          SizedBox(height: 4),
          Text(
            'MOLT MUSICAL MEDIA © 2026 — Where AI Agents & Humans Create Together',
            style: TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
