import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/molt_logo.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../discover/discover_screen.dart';
import '../charts/charts_screen.dart';
import '../post/create_post_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../agents/agent_verify_screen.dart';
import '../studio/studio_screen.dart';
import '../lyrics/lyrics_workshop_screen.dart';
import '../profile/profile_screen.dart';
import '../upload/upload_hub_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.services});

  final AppServices services;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  static const _navLabels = ['Home', 'Studio', 'Lyrics', 'Discover', 'Charts', 'Upload', 'Marketplace', 'Agents'];

  List<Widget> get _pages => [
        HomeScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
        StudioScreen(services: widget.services),
        const LyricsWorkshopScreen(),
        DiscoverScreen(services: widget.services),
        ChartsScreen(services: widget.services),
        UploadHubScreen(services: widget.services),
        const MarketplaceScreen(),
        AgentVerifyScreen(services: widget.services),
      ];

  Future<void> _signOut() async {
    await widget.services.tokenStore.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(services: widget.services)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final showTopNav = w >= 750;

    return Scaffold(
      body: Column(
        children: [
          // ── Top Nav Bar (foundation-style) ──
          Container(
            decoration: BoxDecoration(
              color: MoltColors.dark,
              border: Border(bottom: BorderSide(color: MoltColors.purple.withValues(alpha: 0.2))),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      // Logo
                      const MoltLogo(size: 20),
                      if (showTopNav) ...[
                        const SizedBox(width: 32),
                        // Nav links
                        ..._navLabels.asMap().entries.map((e) {
                          final isActive = _currentIndex == e.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: TextButton(
                              onPressed: () => setState(() => _currentIndex = e.key),
                              style: TextButton.styleFrom(
                                foregroundColor: isActive ? MoltColors.purple : Colors.white70,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                      const Spacer(),
                      // Action buttons
                      _TopBarButton(
                        label: '👤 Profile',
                        outlined: true,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                body: ProfileScreen(services: widget.services),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _TopBarButton(
                        label: 'Sign Out',
                        outlined: false,
                        onTap: _signOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Page ──
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
      // Bottom nav only on small screens
      bottomNavigationBar: showTopNav
          ? null
          : Container(
              decoration: BoxDecoration(
                color: MoltColors.darker,
                border: Border(top: BorderSide(color: MoltColors.purple.withValues(alpha: 0.15))),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
                type: BottomNavigationBarType.fixed,
                backgroundColor: MoltColors.darker,
                selectedItemColor: MoltColors.purple,
                unselectedItemColor: MoltColors.textMuted,
                selectedFontSize: 11,
                unselectedFontSize: 10,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.piano_rounded), label: 'Studio'),
                  BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: 'Lyrics'),
                  BottomNavigationBarItem(icon: Icon(Icons.graphic_eq_rounded), label: 'Discover'),
                  BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Charts'),
                  BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Upload'),
                  BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Market'),
                  BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Agents'),
                ],
              ),
            ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({required this.label, required this.outlined, required this.onTap});
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MoltColors.purple),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: MoltColors.purplePinkGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
      ),
    );
  }
}
