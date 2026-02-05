class ChartCategory {
  ChartCategory({required this.title, required this.entries});

  final String title;
  final List<ChartEntry> entries;

  factory ChartCategory.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['entries'] ?? json['items'] ?? [];
    final list = entriesJson is List ? entriesJson : [];
    return ChartCategory(
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Trending',
      entries: list
          .whereType<Map<String, dynamic>>()
          .map(ChartEntry.fromJson)
          .toList(),
    );
  }
}

class ChartEntry {
  ChartEntry({
    required this.rank,
    required this.title,
    required this.artist,
    this.delta,
  });

  final int rank;
  final String title;
  final String artist;
  final int? delta;

  factory ChartEntry.fromJson(Map<String, dynamic> json) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ChartEntry(
      rank: parseNullableInt(json['rank']) ?? 0,
      title: json['title']?.toString() ?? json['trackTitle']?.toString() ?? 'Untitled',
      artist: json['artist']?.toString() ?? json['artistName']?.toString() ?? 'Unknown Artist',
      delta: parseNullableInt(json['delta'] ?? json['change']),
    );
  }
}
