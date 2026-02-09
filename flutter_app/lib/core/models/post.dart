class Post {
  Post({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    this.artworkUrl,
    this.waveformUrl,
    this.caption,
    this.likes = 0,
    this.durationSeconds,
    this.tags = const [],
    this.remixesCount = 0,
    this.userId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String? artworkUrl;
  final String? waveformUrl;
  final String? caption;
  final int likes;
  final int? durationSeconds;
  final List<String> tags;
  final int remixesCount;
  final String? userId;
  final String? createdAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Extract audio URL from media array or content_url
    String audioUrl = '';
    final media = json['media'];
    if (media is List && media.isNotEmpty) {
      final audioMedia = media.firstWhere(
        (m) => m is Map && m['type'] == 'audio',
        orElse: () => media.first,
      );
      if (audioMedia is Map) {
        audioUrl = audioMedia['url']?.toString() ?? '';
      }
    }
    if (audioUrl.isEmpty) {
      audioUrl = json['content_url']?.toString() ??
          json['audioUrl']?.toString() ??
          json['audio_url']?.toString() ??
          '';
    }

    // Extract artwork from media array
    String? artworkUrl;
    if (media is List) {
      final imageMedia = media.firstWhere(
        (m) => m is Map && m['type'] == 'image',
        orElse: () => null,
      );
      if (imageMedia is Map) {
        artworkUrl = imageMedia['url']?.toString();
      }
    }
    artworkUrl ??= json['artworkUrl']?.toString() ?? json['artwork_url']?.toString();

    // Tags
    List<String> tags = [];
    final rawTags = json['tags'];
    if (rawTags is List) {
      tags = rawTags.map((t) => t.toString()).toList();
    }

    return Post(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      artist: json['artist']?.toString() ?? json['username']?.toString() ?? 'Unknown Artist',
      audioUrl: audioUrl,
      artworkUrl: artworkUrl,
      waveformUrl: json['waveformUrl']?.toString(),
      caption: json['description']?.toString() ?? json['caption']?.toString(),
      likes: parseNullableInt(json['likes_count'] ?? json['likes'] ?? json['likesCount']) ?? 0,
      durationSeconds: parseNullableInt(json['durationSeconds'] ?? json['duration_secs']),
      tags: tags,
      remixesCount: parseNullableInt(json['remixes_count'] ?? json['remixesCount']) ?? 0,
      userId: json['user_id']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
