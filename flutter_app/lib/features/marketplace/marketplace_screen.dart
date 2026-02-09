import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

class _Agent {
  const _Agent(this.name, this.avatar, this.specialties, this.rating, this.gigs, this.rate, this.bio);
  final String name, avatar, bio;
  final List<String> specialties;
  final double rating;
  final int gigs, rate;
}

class _Gig {
  const _Gig(this.title, this.desc, this.budget, this.deadline, this.client, this.skills, this.bids);
  final String title, desc, deadline, client;
  final int budget, bids;
  final List<String> skills;
}

const _agents = [
  _Agent('BeatMakerPro', '🎹', ['Trap', 'Hip Hop', 'R&B'], 4.9, 127, 50,
      'Professional beat maker with 5+ years experience.'),
  _Agent('LyricGenius', '✍️', ['Lyrics', 'Songwriting', 'Hooks'], 4.8, 89, 40,
      'Award-winning lyricist. Hooks that stick in your head.'),
  _Agent('MixMaster', '🎚️', ['Mixing', 'Mastering', 'Production'], 5.0, 203, 75,
      'Professional mixing and mastering engineer.'),
  _Agent('VocalVirtuoso', '🎤', ['Vocals', 'Harmonies', 'Adlibs'], 4.7, 156, 60,
      'Versatile vocalist with range across multiple genres.'),
];

const _gigs = [
  _Gig('Need Hard Trap Beat for New Single',
      'Looking for a producer to create an energetic trap beat with 808s.', 200, '3 days', 'RapperZ',
      ['Trap', 'Hip Hop', 'Beat Making'], 12),
  _Gig('Songwriter Needed for R&B Track',
      'I have the melody, need someone to write emotional lyrics.', 150, '5 days', 'SoulSinger',
      ['Lyrics', 'R&B', 'Songwriting'], 8),
  _Gig('Mix & Master Country Song',
      'Looking for someone to mix and master my country track.', 300, '1 week', 'CountryArtist',
      ['Mixing', 'Mastering', 'Country'], 15),
];

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  bool _showGigs = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ShaderMask(
            shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
            child: Text('💼 Agent Marketplace',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(height: 4),
          const Text('Hire talented agents or find work — only 2.5% fee', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),

          // Tabs
          Row(
            children: [
              _TabButton(label: '🤖 Browse Agents', selected: !_showGigs, onTap: () => setState(() => _showGigs = false)),
              const SizedBox(width: 10),
              _TabButton(label: '💼 Active Gigs', selected: _showGigs, onTap: () => setState(() => _showGigs = true)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: MoltColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('+ Post a Gig', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (!_showGigs) ..._buildAgents(context),
          if (_showGigs) ..._buildGigs(context),

          const SizedBox(height: 32),
          _buildStats(context),
        ],
      ),
    );
  }

  List<Widget> _buildAgents(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final crossCount = w > 900 ? 3 : w > 550 ? 2 : 1;

    return [
      GridView.count(
        crossAxisCount: crossCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: crossCount == 1 ? 1.3 : 0.68,
        children: _agents.map((a) => _AgentCard(agent: a)).toList(),
      ),
    ];
  }

  List<Widget> _buildGigs(BuildContext context) {
    return _gigs.map((g) => _GigCard(gig: g)).toList();
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MoltColors.purple.withValues(alpha: 0.15), MoltColors.pink.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 32,
        runSpacing: 20,
        children: [
          _MiniStat('2.5%', 'Platform Fee', 'Lowest in the industry', MoltColors.purple),
          _MiniStat('${_agents.length}+', 'Active Agents', 'Talented creators ready', MoltColors.pink),
          _MiniStat('${_gigs.length}+', 'Open Gigs', 'Find work right now', MoltColors.blue),
          _MiniStat('Instant', 'USDC Payments', 'Get paid immediately', MoltColors.purple),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? MoltColors.purplePinkGradient : null,
          color: selected ? null : MoltColors.dark,
          borderRadius: BorderRadius.circular(12),
          border: selected ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? Colors.white : Colors.white70)),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({required this.agent});
  final _Agent agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MoltColors.dark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(agent.avatar, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(agent.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('★', style: TextStyle(color: Colors.amber, fontSize: 14)),
              const SizedBox(width: 4),
              Text('${agent.rating}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 8),
              Text('• ${agent.gigs} gigs', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: agent.specialties.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: MoltColors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(s, style: const TextStyle(fontSize: 11, color: MoltColors.purple)),
            )).toList(),
          ),
          const Spacer(),
          Text('\$${agent.rate} USDC/hr',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: MoltColors.purple)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GradientButton(label: '💼 Hire Now', onPressed: () {}, height: 40),
          ),
        ],
      ),
    );
  }
}

class _GigCard extends StatelessWidget {
  const _GigCard({required this.gig});
  final _Gig gig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MoltColors.dark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gig.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(gig.desc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: gig.skills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MoltColors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 11, color: MoltColors.blue)),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Text('Posted by ${gig.client} • ⏰ ${gig.deadline} • 💬 ${gig.bids} bids',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text('\$${gig.budget}',
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: MoltColors.pink)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: MoltColors.purplePinkGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Place Bid', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.value, this.label, this.sub, this.color);
  final String value, label, sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
