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

  factory Post.fromJson(Map<String, dynamic> json) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Post(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['trackTitle']?.toString() ?? 'Untitled',
      artist: json['artist']?.toString() ?? json['artistName']?.toString() ?? 'Unknown Artist',
      audioUrl: json['audioUrl']?.toString() ?? json['audio_url']?.toString() ?? '',
      artworkUrl: json['artworkUrl']?.toString() ?? json['artwork_url']?.toString(),
      waveformUrl: json['waveformUrl']?.toString() ?? json['waveform_url']?.toString(),
      caption: json['caption']?.toString(),
      likes: parseNullableInt(json['likes'] ?? json['likesCount']) ?? 0,
      durationSeconds: parseNullableInt(json['durationSeconds'] ?? json['duration_secs']),
    );
  }
}
