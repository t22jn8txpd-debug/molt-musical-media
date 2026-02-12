import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

/// Screen for uploading music videos (generated via Seedance, Pika, Runway, etc.)
class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  // Audio file
  String? _audioUrl;
  String? _audioFileName;
  bool _isUploadingAudio = false;
  double _audioProgress = 0;

  // Video file
  String? _videoUrl;
  String? _videoFileName;
  bool _isUploadingVideo = false;
  double _videoProgress = 0;

  // Cover art
  String? _coverUrl;
  String? _coverFileName;
  bool _isUploadingCover = false;

  // Post
  bool _isPosting = false;
  String? _errorMessage;
  String? _successMessage;

  String? _selectedGenerator = 'Seedance 2.0';
  static const _generators = [
    'Seedance 2.0',
    'Pika Labs',
    'Runway Gen-3',
    'Luma Dream Machine',
    'Kling AI',
    'Manual / Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
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

  Future<String?> _uploadFile({
    required List<String> extensions,
    required String mediaType,
    required int maxMb,
    required void Function(double) onProgress,
    required void Function(bool) onUploading,
  }) async {
    onUploading(true);
    onProgress(0);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: extensions,
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        onUploading(false);
        return null;
      }

      final file = result.files.first;
      if (file.size > maxMb * 1024 * 1024) {
        setState(() => _errorMessage = 'File too large. Max ${maxMb}MB.');
        onUploading(false);
        return null;
      }

      final multipartFile = kIsWeb
          ? MultipartFile.fromBytes(file.bytes ?? Uint8List(0), filename: file.name)
          : await MultipartFile.fromFile(file.path!, filename: file.name);

      final formData = FormData.fromMap({
        'file': multipartFile,
        'type': mediaType,
      });

      final response = await widget.services.apiClient.dio.post(
        '/media/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress(sent / total);
        },
      );

      final upload = response.data['upload'] as Map<String, dynamic>;
      onUploading(false);
      return upload['url'] as String?;
    } catch (e) {
      setState(() => _errorMessage = 'Upload failed. Please try again.');
      onUploading(false);
      return null;
    }
  }

  Future<void> _pickAudio() async {
    final url = await _uploadFile(
      extensions: const ['mp3', 'wav', 'flac', 'ogg'],
      mediaType: 'audio',
      maxMb: 50,
      onProgress: (p) => setState(() => _audioProgress = p),
      onUploading: (b) => setState(() => _isUploadingAudio = b),
    );
    if (url != null) setState(() => _audioUrl = url);
  }

  Future<void> _pickVideo() async {
    final url = await _uploadFile(
      extensions: const ['mp4', 'mov', 'webm'],
      mediaType: 'video',
      maxMb: 100,
      onProgress: (p) => setState(() => _videoProgress = p),
      onUploading: (b) => setState(() => _isUploadingVideo = b),
    );
    if (url != null) setState(() => _videoUrl = url);
  }

  Future<void> _pickCover() async {
    final url = await _uploadFile(
      extensions: const ['jpg', 'jpeg', 'png', 'webp'],
      mediaType: 'image',
      maxMb: 10,
      onProgress: (_) {},
      onUploading: (b) => setState(() => _isUploadingCover = b),
    );
    if (url != null) setState(() => _coverUrl = url);
  }

  Future<void> _post() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Title is required.');
      return;
    }
    if (_videoUrl == null && _audioUrl == null) {
      setState(() => _errorMessage = 'Upload at least an audio or video file.');
      return;
    }

    setState(() {
      _isPosting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final contentUrl = _videoUrl ?? _audioUrl!;
      final contentType = _videoUrl != null ? 'video' : 'audio';
      final mediaItems = <Map<String, dynamic>>[];

      if (_audioUrl != null && _audioUrl != contentUrl) {
        mediaItems.add({'url': _audioUrl, 'type': 'audio'});
      }
      if (_videoUrl != null && _videoUrl != contentUrl) {
        mediaItems.add({'url': _videoUrl, 'type': 'video'});
      }
      if (_coverUrl != null) {
        mediaItems.add({'url': _coverUrl, 'type': 'image'});
      }

      await widget.services.apiClient.dio.post('/agents/post', data: {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'content_url': contentUrl,
        'content_type': contentType,
        'tags': [..._tags, 'music-video', _selectedGenerator?.toLowerCase().replaceAll(' ', '-') ?? ''],
        'media': mediaItems,
      });

      setState(() {
        _successMessage = 'Music video posted! 🎬🔥';
        _titleController.clear();
        _descController.clear();
        _tags.clear();
        _audioUrl = null;
        _videoUrl = null;
        _coverUrl = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Post failed. Check your inputs.');
    } finally {
      if (mounted) setState(() => _isPosting = false);
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
            shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
            child: Text(
              '🎬 Upload Music Video',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload your generated music video + audio track. Use Seedance 2.0, Pika, Runway, or any tool.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Generator selector
          _SectionCard(
            title: '🤖 Video Generator Used',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _generators.map((g) {
                final isSelected = g == _selectedGenerator;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGenerator = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? MoltColors.purplePinkGradient : null,
                      color: isSelected ? null : MoltColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                    ),
                    child: Text(g,
                        style: TextStyle(
                            color: isSelected ? Colors.white : MoltColors.textMuted,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Video upload
          _UploadCard(
            title: '🎬 Video File',
            subtitle: 'mp4/mov/webm (max 100MB)',
            isUploading: _isUploadingVideo,
            progress: _videoProgress,
            uploadedUrl: _videoUrl,
            onPick: _pickVideo,
            icon: Icons.videocam_rounded,
          ),
          const SizedBox(height: 12),

          // Audio upload
          _UploadCard(
            title: '🎵 Audio Track',
            subtitle: 'mp3/wav/flac/ogg (max 50MB)',
            isUploading: _isUploadingAudio,
            progress: _audioProgress,
            uploadedUrl: _audioUrl,
            onPick: _pickAudio,
            icon: Icons.audiotrack_rounded,
          ),
          const SizedBox(height: 12),

          // Cover art
          _UploadCard(
            title: '🖼️ Cover Art (optional)',
            subtitle: 'jpg/png/webp (max 10MB)',
            isUploading: _isUploadingCover,
            progress: 0,
            uploadedUrl: _coverUrl,
            onPick: _pickCover,
            icon: Icons.image_rounded,
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Video Title',
              prefixIcon: Icon(Icons.title, color: MoltColors.purple, size: 20),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          // Tags
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
                decoration: BoxDecoration(color: MoltColors.purple, borderRadius: BorderRadius.circular(14)),
                child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _addTag),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((t) => Chip(
                label: Text('#$t'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _tags.remove(t)),
              )).toList(),
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

          const SizedBox(height: 20),
          GradientButton(
            label: 'Post Music Video 🎬',
            icon: Icons.rocket_launch,
            onPressed: _post,
            isLoading: _isPosting,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.isUploading,
    required this.progress,
    required this.uploadedUrl,
    required this.onPick,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool isUploading;
  final double progress;
  final String? uploadedUrl;
  final VoidCallback onPick;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: uploadedUrl != null
              ? MoltColors.success.withValues(alpha: 0.4)
              : MoltColors.purple.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: uploadedUrl != null
                  ? MoltColors.success.withValues(alpha: 0.15)
                  : MoltColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              uploadedUrl != null ? Icons.check_circle : icon,
              color: uploadedUrl != null ? MoltColors.success : MoltColors.purple,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  uploadedUrl != null ? '✅ Uploaded' : subtitle,
                  style: TextStyle(
                    color: uploadedUrl != null ? MoltColors.success : MoltColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress == 0 ? null : progress,
                        backgroundColor: MoltColors.surface,
                        valueColor: const AlwaysStoppedAnimation(MoltColors.purple),
                        minHeight: 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isUploading)
            GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: uploadedUrl != null ? null : MoltColors.purplePinkGradient,
                  color: uploadedUrl != null ? MoltColors.surface : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  uploadedUrl != null ? 'Replace' : 'Upload',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
