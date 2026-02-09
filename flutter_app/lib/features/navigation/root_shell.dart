import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/molt_logo.dart';
import '../auth/login_screen.dart';
import '../charts/charts_screen.dart';
import '../feed/feed_screen.dart';
import '../post/create_post_screen.dart';
import '../agents/agent_verify_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.services});

  final AppServices services;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        FeedScreen(services: widget.services),
        CreatePostScreen(services: widget.services),
        ChartsScreen(services: widget.services),
        AgentVerifyScreen(services: widget.services),
      ];

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.graphic_eq_rounded), label: 'Feed'),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Post'),
    BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Charts'),
    BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Agent'),
  ];

  static const _railDestinations = [
    NavigationRailDestination(icon: Icon(Icons.graphic_eq_rounded), label: Text('Feed')),
    NavigationRailDestination(icon: Icon(Icons.add_circle_outline), label: Text('Post')),
    NavigationRailDestination(icon: Icon(Icons.leaderboard_rounded), label: Text('Charts')),
    NavigationRailDestination(icon: Icon(Icons.smart_toy_outlined), label: Text('Agent')),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;

        final appBar = AppBar(
          title: const MoltLogo(size: 22),
          actions: [
            IconButton(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Sign out',
            ),
            const SizedBox(width: 8),
          ],
        );

        if (useRail) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) => setState(() => _currentIndex = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: _railDestinations,
                ),
                VerticalDivider(width: 1, color: MoltColors.purple.withValues(alpha: 0.15)),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _pages),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: MoltColors.purple.withValues(alpha: 0.15)),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: _navItems,
            ),
          ),
        );
      },
    );
  }
}
