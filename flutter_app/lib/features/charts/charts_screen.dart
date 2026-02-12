import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../core/models/chart.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_state.dart';
import 'charts_service.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<List<ChartCategory>> _chartsFuture;

  @override
  void initState() {
    super.initState();
    _chartsFuture = ChartsService(widget.services.apiClient).fetchCharts();
  }

  Future<void> _refresh() async {
    setState(() {
      _chartsFuture = ChartsService(widget.services.apiClient).fetchCharts();
    });
    await _chartsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChartCategory>>(
      future: _chartsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(label: 'Syncing leaderboards...');
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const EmptyState(
            title: 'No charts yet',
            message: 'Charts will appear once tracks start getting plays and likes.',
            icon: Icons.leaderboard_rounded,
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                indicatorColor: MoltColors.purple,
                labelColor: MoltColors.purple,
                unselectedLabelColor: MoltColors.textMuted,
                tabs: [
                  for (final cat in categories) Tab(text: cat.title),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  color: MoltColors.purple,
                  onRefresh: _refresh,
                  child: TabBarView(
                    children: [
                      for (final cat in categories)
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: cat.entries.length,
                          itemBuilder: (context, index) {
                            return _ChartRow(entry: cat.entries[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow({required this.entry});

  final ChartEntry entry;

  @override
  Widget build(BuildContext context) {
    final delta = entry.delta ?? 0;
    final deltaColor = delta == 0
        ? MoltColors.textMuted
        : delta > 0
            ? MoltColors.success
            : MoltColors.error;

    final isTop3 = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isTop3 ? MoltColors.cardGradient : null,
        color: isTop3 ? null : MoltColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop3
              ? MoltColors.purple.withValues(alpha: 0.3)
              : MoltColors.purple.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isTop3 ? MoltColors.purplePinkGradient : null,
              color: isTop3 ? null : MoltColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isTop3 ? Colors.white : MoltColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  entry.artist,
                  style: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Delta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: deltaColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              delta == 0 ? '—' : (delta > 0 ? '+$delta' : '$delta'),
              style: TextStyle(
                color: deltaColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
