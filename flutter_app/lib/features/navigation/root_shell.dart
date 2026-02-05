import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../auth/login_screen.dart';
import '../charts/charts_screen.dart';
import '../feed/feed_screen.dart';

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
        ChartsScreen(services: widget.services),
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
        if (useRail) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Molt Musical Media'),
              actions: [
                IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.graphic_eq), label: Text('Feed')),
                    NavigationRailDestination(icon: Icon(Icons.leaderboard), label: Text('Charts')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _currentIndex, children: _pages)),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Molt Musical Media'),
            actions: [
              IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'Feed'),
              BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Charts'),
            ],
          ),
        );
      },
    );
  }
}
