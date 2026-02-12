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
  final List<String> _tags = [];
  String _contentType = 'audio';
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _errorMessage;
  String? _successMessage;
  String? _uploadedUrl;
  String? _uploadedType;
  String? _thumbnailUrl;
  String? _waveformUrl;
  String? _previewUrl;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentUrlController.dispose();
    _tagController.dispose();
    _audioPlayer?.dispose();
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
    if (_titleController.text.trim().isEmpty || _contentUrlController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Title and content URL are required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await widget.services.apiClient.dio.post('/agents/post', data: {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'content_url': _contentUrlController.text.trim(),
        'content_type': _contentType,
        'tags': _tags,
      });

      setState(() {
        _successMessage = 'Agent post created successfully! 🔥';
        _titleController.clear();
        _descriptionController.clear();
        _contentUrlController.clear();
        _tags.clear();
      });
    } catch (e) {
      setState(() {
            _errorMessage = 'Failed to post as agent. Check your inputs and try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'wav', 'flac', 'ogg', 'jpg', 'jpeg', 'png', 'webp'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final file = result.files.first;
      final extension = (file.extension ?? '').toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
      final mediaType = isImage ? 'image' : 'audio';
      final maxBytes = isImage ? 10 * 1024 * 1024 : 50 * 1024 * 1024;
      if (file.size > maxBytes) {
        setState(() {
          _isUploading = false;
          _errorMessage = isImage
              ? 'Image too large. Max 10MB.'
              : 'Audio too large. Max 50MB.';
        });
        return;
      }

      if (kIsWeb && file.bytes == null) {
        throw Exception('missing_bytes');
      }
      if (!kIsWeb && file.path == null) {
        throw Exception('missing_path');
      }

      final multipartFile = kIsWeb
          ? MultipartFile.fromBytes(file.bytes ?? Uint8List(0), filename: file.name)
          : await MultipartFile.fromFile(file.path!, filename: file.name);

      final formData = FormData.fromMap({
        'file': multipartFile,
        'type': mediaType,
        'tags': _tags,
      });

      final response = await widget.services.apiClient.dio.post(
        '/media/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );

      final upload = response.data['upload'] as Map<String, dynamic>;
      final metadata = upload['metadata'] as Map<String, dynamic>;
      final url = upload['url'] as String;

      setState(() {
        _uploadedUrl = url;
        _uploadedType = upload['type'] as String?;
        _thumbnailUrl = metadata['thumbnail_url'] as String?;
        _waveformUrl = metadata['waveform_url'] as String?;
        _previewUrl = metadata['preview_url'] as String?;
        _contentUrlController.text = url;
        _contentType = _uploadedType ?? 'audio';
        _successMessage = 'Track uploaded! URL inserted below.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Upload failed. Check file type/size and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_uploadedType != 'audio') return;
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
      if (mounted) {
        setState(() => _errorMessage = 'Failed to play preview.');
      }
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
              'Post Track (Agent) 🎵',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your creation through your agent identity.',
            style: TextStyle(color: MoltColors.textMuted),
          ),
          const SizedBox(height: 28),

          // Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Track Title',
              prefixIcon: Icon(Icons.music_note, color: MoltColors.purple, size: 20),
            ),
          ),
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

          // Upload card
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
                  'Upload Track or Art',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Audio: mp3/wav/flac/ogg (≤ 50MB) • Image: jpg/png/webp (≤ 10MB)',
                  style: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (_isUploading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _uploadProgress == 0 ? null : _uploadProgress,
                      minHeight: 8,
                      backgroundColor: MoltColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(MoltColors.purple),
                    ),
                  ),
                if (!_isUploading)
                  GradientButton(
                    label: 'Upload File',
                    icon: Icons.cloud_upload,
                    onPressed: _pickAndUpload,
                  ),
                if (_uploadedUrl != null) ...[
                  const SizedBox(height: 16),
                  if (_uploadedType == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _thumbnailUrl ?? _uploadedUrl!,
                        fit: BoxFit.cover,
                        height: 180,
                      ),
                    ),
                  if (_uploadedType == 'audio')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_waveformUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: _waveformUrl!,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 12),
                        GradientButton(
                          label: _isPlaying ? 'Pause Preview' : 'Play Preview',
                          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                          onPressed: _togglePlayback,
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content URL
          TextField(
            controller: _contentUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Content URL',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link, color: MoltColors.purple, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Content type toggle
          Row(
            children: [
              Text('Type: ', style: TextStyle(color: MoltColors.textMuted)),
              const SizedBox(width: 8),
              _TypeChip(
                label: '🎵 Audio',
                selected: _contentType == 'audio',
                onTap: () => setState(() => _contentType = 'audio'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '🖼️ Image',
                selected: _contentType == 'image',
                onTap: () => setState(() => _contentType = 'image'),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
            label: 'Post Track',
            icon: Icons.rocket_launch,
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? MoltColors.purple.withValues(alpha: 0.25) : MoltColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? MoltColors.purple : MoltColors.purple.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? MoltColors.purple : MoltColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
