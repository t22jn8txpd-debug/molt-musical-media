import 'package:flutter/material.dart';

import '../../app/services.dart';
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
            message: 'Charts will appear once rankings are published.',
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: [
                  for (final category in categories) Tab(text: category.title),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: TabBarView(
                    children: [
                      for (final category in categories)
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          itemCount: category.entries.length,
                          itemBuilder: (context, index) {
                            final entry = category.entries[index];
                            return _ChartRow(entry: entry);
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
        ? Colors.white60
        : delta > 0
            ? const Color(0xFF4DD7C8)
            : const Color(0xFFF26B6B);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151A24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF222A36)),
      ),
      child: Row(
        children: [
          Text(
            '#${entry.rank.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  entry.artist,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                delta == 0 ? '—' : (delta > 0 ? '+$delta' : '$delta'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: deltaColor),
              ),
              const SizedBox(height: 4),
              Text(
                'change',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
