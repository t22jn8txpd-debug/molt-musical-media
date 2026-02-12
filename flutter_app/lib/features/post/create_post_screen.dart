import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/widgets/gradient_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentUrlController = TextEditingController();
  final _tagController = TextEditingController();
  final _albumTitleController = TextEditingController();
  final List<String> _tags = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _errorMessage;
  String? _successMessage;
  String? _uploadedUrl;
  String? _thumbnailUrl;
  String? _waveformUrl;
  String? _previewUrl;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  // Cover art
  bool _isUploadingCover = false;
  double _coverUploadProgress = 0;
  String? _coverArtUrl;

  // Album/EP mode
  bool _isAlbumMode = false;
  final List<_TrackEntry> _albumTracks = [];
  bool _isUploadingTrack = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentUrlController.dispose();
    _tagController.dispose();
    _albumTitleController.dispose();
    _audioPlayer?.dispose();
    for (final t in _albumTracks) {
      t.titleController.dispose();
    }
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 20) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _submit() async {
    if (_isAlbumMode) {
      await _submitAlbum();
    } else {
      await _submitSingle();
    }
  }

  Future<void> _submitSingle() async {
    if (_titleController.text.trim().isEmpty || _contentUrlController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Title and audio file are required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final media = <Map<String, String>>[];
      media.add({'url': _contentUrlController.text.trim(), 'type': 'audio'});
      if (_coverArtUrl != null) {
        media.add({'url': _coverArtUrl!, 'type': 'image'});
      }

      await widget.services.apiClient.dio.post('/agents/post', data: {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'content_url': _contentUrlController.text.trim(),
        'content_type': 'audio',
        'tags': _tags,
        'media': media,
      });

      setState(() {
        _successMessage = 'Track posted! 🔥';
        _titleController.clear();
        _descriptionController.clear();
        _contentUrlController.clear();
        _tags.clear();
        _uploadedUrl = null;
        _coverArtUrl = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to post. Check your inputs and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAlbum() async {
    final albumTitle = _albumTitleController.text.trim();
    if (albumTitle.isEmpty) {
      setState(() => _errorMessage = 'Album title is required.');
      return;
    }
    if (_albumTracks.isEmpty) {
      setState(() => _errorMessage = 'Add at least one track.');
      return;
    }
    for (final t in _albumTracks) {
      if (t.titleController.text.trim().isEmpty || t.url == null) {
        setState(() => _errorMessage = 'All tracks need a title and uploaded file.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final albumTag = 'album:${albumTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}';
      final allTags = [..._tags, albumTag];

      for (int i = 0; i < _albumTracks.length; i++) {
        final track = _albumTracks[i];
        final media = <Map<String, String>>[];
        media.add({'url': track.url!, 'type': 'audio'});
        if (_coverArtUrl != null) {
          media.add({'url': _coverArtUrl!, 'type': 'image'});
        }

        await widget.services.apiClient.dio.post('/agents/post', data: {
          'title': '${track.titleController.text.trim()} — $albumTitle',
          'description': _descriptionController.text.trim().isEmpty
              ? 'Track ${i + 1} of $albumTitle'
              : _descriptionController.text.trim(),
          'content_url': track.url,
          'content_type': 'audio',
          'tags': allTags,
          'media': media,
        });
      }

      setState(() {
        _successMessage = 'Album "$albumTitle" posted (${_albumTracks.length} tracks)! 🔥';
        _albumTitleController.clear();
        _descriptionController.clear();
        for (final t in _albumTracks) {
          t.titleController.dispose();
        }
        _albumTracks.clear();
        _tags.clear();
        _coverArtUrl = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to post album. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAudio() async {
    setState(() {
      _errorMessage = null;
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'wav', 'flac', 'ogg'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }

      final file = result.files.first;
      if (file.size > 50 * 1024 * 1024) {
        setState(() {
          _isUploading = false;
          _errorMessage = 'Audio too large. Max 50MB.';
        });
        return;
      }

      final url = await _uploadFile(file, 'audio', (p) => setState(() => _uploadProgress = p));

      setState(() {
        _uploadedUrl = url['url'];
        _thumbnailUrl = url['thumbnail_url'];
        _waveformUrl = url['waveform_url'];
        _previewUrl = url['preview_url'];
        _contentUrlController.text = url['url']!;
        _successMessage = 'Track uploaded! 🎶';
      });
    } catch (e) {
      setState(() => _errorMessage = 'Upload failed. Check file and try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndUploadCover() async {
    setState(() {
      _errorMessage = null;
      _isUploadingCover = true;
      _coverUploadProgress = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploadingCover = false);
        return;
      }

      final file = result.files.first;
      if (file.size > 10 * 1024 * 1024) {
        setState(() {
          _isUploadingCover = false;
          _errorMessage = 'Image too large. Max 10MB.';
        });
        return;
      }

      final url = await _uploadFile(file, 'image', (p) => setState(() => _coverUploadProgress = p));

      setState(() {
        _coverArtUrl = url['url'];
        _successMessage = 'Cover art uploaded! 🎨';
      });
    } catch (e) {
      setState(() => _errorMessage = 'Cover upload failed.');
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  Future<void> _pickAndUploadAlbumTrack() async {
    if (_albumTracks.length >= 20) {
      setState(() => _errorMessage = 'Max 20 tracks per album.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isUploadingTrack = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'wav', 'flac', 'ogg'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploadingTrack = false);
        return;
      }

      final file = result.files.first;
      if (file.size > 50 * 1024 * 1024) {
        setState(() {
          _isUploadingTrack = false;
          _errorMessage = 'Audio too large. Max 50MB.';
        });
        return;
      }

      final url = await _uploadFile(file, 'audio', (_) {});

      setState(() {
        _albumTracks.add(_TrackEntry(
          titleController: TextEditingController(text: file.name.replaceAll(RegExp(r'\.[^.]+$'), '')),
          url: url['url'],
          fileName: file.name,
        ));
      });
    } catch (e) {
      setState(() => _errorMessage = 'Track upload failed.');
    } finally {
      if (mounted) setState(() => _isUploadingTrack = false);
    }
  }

  Future<Map<String, String?>> _uploadFile(PlatformFile file, String type, void Function(double) onProgress) async {
    if (kIsWeb && file.bytes == null) throw Exception('missing_bytes');
    if (!kIsWeb && file.path == null) throw Exception('missing_path');

    final multipartFile = kIsWeb
        ? MultipartFile.fromBytes(file.bytes ?? Uint8List(0), filename: file.name)
        : await MultipartFile.fromFile(file.path!, filename: file.name);

    final formData = FormData.fromMap({
      'file': multipartFile,
      'type': type,
    });

    final response = await widget.services.apiClient.dio.post(
      '/media/upload',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    );

    final upload = response.data['upload'] as Map<String, dynamic>;
    final metadata = (upload['metadata'] as Map<String, dynamic>?) ?? {};
    return {
      'url': upload['url'] as String?,
      'thumbnail_url': metadata['thumbnail_url'] as String?,
      'waveform_url': metadata['waveform_url'] as String?,
      'preview_url': metadata['preview_url'] as String?,
    };
  }

  Future<void> _togglePlayback() async {
    final url = _previewUrl ?? _uploadedUrl;
    if (url == null) return;

    _audioPlayer ??= AudioPlayer();
    if (_isPlaying) {
      await _audioPlayer?.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    try {
      await _audioPlayer?.setUrl(url);
      await _audioPlayer?.play();
      if (mounted) setState(() => _isPlaying = true);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Failed to play preview.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // Header
          ShaderMask(
            shaderCallback: (bounds) => MoltColors.purplePinkGradient.createShader(bounds),
            child: Text(
              'Post Track 🎵',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your creation with the world.',
            style: TextStyle(color: MoltColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Single / Album toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MoltColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isAlbumMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: !_isAlbumMode ? MoltColors.purplePinkGradient : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '🎵 Single Track',
                          style: TextStyle(
                            color: !_isAlbumMode ? Colors.white : MoltColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isAlbumMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: _isAlbumMode ? MoltColors.purplePinkGradient : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '💿 Album / EP',
                          style: TextStyle(
                            color: _isAlbumMode ? Colors.white : MoltColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Title (single) or Album title
          if (_isAlbumMode) ...[
            TextField(
              controller: _albumTitleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Album / EP Title',
                prefixIcon: Icon(Icons.album, color: MoltColors.purple, size: 20),
              ),
            ),
          ] else ...[
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Track Title',
                prefixIcon: Icon(Icons.music_note, color: MoltColors.purple, size: 20),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.notes, color: MoltColors.purple, size: 20),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // Cover Art Upload
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: MoltColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎨 Cover Art',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'jpg / png / webp (≤ 10MB)',
                  style: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (_isUploadingCover)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _coverUploadProgress == 0 ? null : _coverUploadProgress,
                      minHeight: 8,
                      backgroundColor: MoltColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(MoltColors.pink),
                    ),
                  )
                else if (_coverArtUrl != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _coverArtUrl!,
                          fit: BoxFit.cover,
                          height: 160,
                          width: 160,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _coverArtUrl = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  GradientButton(
                    label: 'Upload Cover Art',
                    icon: Icons.image,
                    onPressed: _pickAndUploadCover,
                    height: 44,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Audio Upload section
          if (!_isAlbumMode) ...[
            // Single track upload
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: MoltColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎵 Upload Audio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'mp3 / wav / flac / ogg (≤ 50MB)',
                    style: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  if (_isUploading)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _uploadProgress == 0 ? null : _uploadProgress,
                        minHeight: 8,
                        backgroundColor: MoltColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(MoltColors.purple),
                      ),
                    )
                  else
                    GradientButton(
                      label: _uploadedUrl != null ? 'Replace Audio' : 'Upload Audio',
                      icon: Icons.cloud_upload,
                      onPressed: _pickAndUploadAudio,
                      height: 44,
                    ),
                  if (_uploadedUrl != null) ...[
                    const SizedBox(height: 12),
                    if (_waveformUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _waveformUrl!,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    GradientButton(
                      label: _isPlaying ? 'Pause Preview' : 'Play Preview',
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: _togglePlayback,
                      height: 40,
                      gradient: MoltColors.purpleBlueGradient,
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Album tracks
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: MoltColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🎵 Tracks (${_albumTracks.length}/20)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const Spacer(),
                      if (_isUploadingTrack)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: MoltColors.purple),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._albumTracks.asMap().entries.map((e) {
                    final i = e.key;
                    final track = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: MoltColors.purplePinkGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: track.titleController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Track title',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _albumTracks[i].titleController.dispose();
                                _albumTracks.removeAt(i);
                              });
                            },
                            child: const Icon(Icons.remove_circle_outline, color: MoltColors.error, size: 22),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  GradientButton(
                    label: 'Add Track',
                    icon: Icons.add,
                    onPressed: _isUploadingTrack ? null : _pickAndUploadAlbumTrack,
                    height: 42,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Hidden content URL field (kept for compatibility)
          if (!_isAlbumMode)
            TextField(
              controller: _contentUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Content URL (auto-filled on upload)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link, color: MoltColors.purple, size: 20),
              ),
            ),
          if (!_isAlbumMode) const SizedBox(height: 16),

          // Tags input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Add tag',
                    prefixIcon: Icon(Icons.tag, color: MoltColors.purple, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: MoltColors.purple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addTag,
                ),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
          ],

          // Messages
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MoltColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MoltColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(_errorMessage!, style: const TextStyle(color: MoltColors.error, fontSize: 13)),
            ),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MoltColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MoltColors.success.withValues(alpha: 0.3)),
              ),
              child: Text(_successMessage!, style: const TextStyle(color: MoltColors.success, fontSize: 13)),
            ),
          ],

          const SizedBox(height: 28),
          GradientButton(
            label: _isAlbumMode ? 'Post Album' : 'Post Track',
            icon: Icons.rocket_launch,
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

class _TrackEntry {
  _TrackEntry({required this.titleController, this.url, this.fileName});
  final TextEditingController titleController;
  final String? url;
  final String? fileName;
}
