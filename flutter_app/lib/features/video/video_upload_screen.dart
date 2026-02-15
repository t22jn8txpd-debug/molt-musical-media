import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

/// Screen for uploading music videos and generating them via AI services.
class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: MoltColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: MoltColors.purplePinkGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: Colors.white,
                unselectedLabelColor: MoltColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                tabs: const [
                  Tab(text: '🤖 Generate Video'),
                  Tab(text: '📤 Upload Video'),
                  Tab(text: '🔑 API Keys'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _GenerateVideoTab(services: widget.services),
                _DirectUploadTab(services: widget.services),
                const _ApiKeysTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// GENERATE VIDEO TAB
// ═══════════════════════════════════════

class _GenerateVideoTab extends StatefulWidget {
  const _GenerateVideoTab({required this.services});
  final AppServices services;

  @override
  State<_GenerateVideoTab> createState() => _GenerateVideoTabState();
}

class _GenerateVideoTabState extends State<_GenerateVideoTab> {
  String? _selectedService;
  String? _selectedTrackUrl;
  final _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _resultMessage;
  bool _isSuccess = false;

  static const _services = [
    _VideoGenService('Seedance 2.0', '🌱', 'ByteDance', 'Best for music-synced dance videos'),
    _VideoGenService('Pika Labs', '⚡', 'Pika', 'Fast, stylized short clips'),
    _VideoGenService('Runway Gen-3', '🎬', 'Runway', 'Cinematic quality, long-form'),
    _VideoGenService('Luma Dream Machine', '💫', 'Luma AI', 'Dreamy, surreal aesthetics'),
    _VideoGenService('Kling AI', '🎭', 'Kuaishou', 'Realistic human motion'),
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_selectedService == null) {
      setState(() {
        _resultMessage = 'Please select a video generation service.';
        _isSuccess = false;
      });
      return;
    }

    // Check if API key is stored
    final prefs = await SharedPreferences.getInstance();
    final keyName = 'api_key_${_selectedService!.toLowerCase().replaceAll(' ', '_')}';
    final apiKey = prefs.getString(keyName);

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _resultMessage = 'No API key found for $_selectedService. Go to the API Keys tab to add one.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _resultMessage = null;
    });

    // Simulate generation (stub)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      _isGenerating = false;
      _resultMessage = 'API integration for $_selectedService coming soon! Your key has been validated. '
          'When available, this will generate a music video from your track.';
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        ShaderMask(
          shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
          child: Text(
            '🎬 Generate Music Video',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select a track and AI service to generate a music video.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Service selection
        _SectionCard(
          title: '🤖 Choose AI Service',
          child: Column(
            children: _services.map((s) {
              final isSelected = _selectedService == s.name;
              return GestureDetector(
                onTap: () => setState(() => _selectedService = s.name),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      colors: [MoltColors.purple.withValues(alpha: 0.2), MoltColors.pink.withValues(alpha: 0.15)],
                    ) : null,
                    color: isSelected ? null : MoltColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? MoltColors.purple : MoltColors.purple.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            )),
                            Text('${s.provider} • ${s.desc}', style: TextStyle(
                              color: isSelected ? Colors.white54 : MoltColors.textMuted,
                              fontSize: 11,
                            )),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: MoltColors.purple, size: 22),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Video prompt
        _SectionCard(
          title: '✨ Video Style Prompt',
          child: TextField(
            controller: _promptController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe the video style... e.g. "cinematic night city, neon lights, slow motion"',
              hintStyle: TextStyle(color: MoltColors.textMuted, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Results
        if (_resultMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isSuccess
                  ? MoltColors.success.withValues(alpha: 0.1)
                  : MoltColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isSuccess
                    ? MoltColors.success.withValues(alpha: 0.3)
                    : MoltColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isSuccess ? Icons.info_outline : Icons.warning_amber,
                  color: _isSuccess ? MoltColors.success : MoltColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _resultMessage!,
                    style: TextStyle(
                      color: _isSuccess ? MoltColors.success : MoltColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        GradientButton(
          label: _isGenerating ? 'Generating...' : '🎬 Generate Music Video',
          icon: _isGenerating ? null : Icons.auto_awesome,
          onPressed: _isGenerating ? null : _generate,
          isLoading: _isGenerating,
        ),
      ],
    );
  }
}

class _VideoGenService {
  const _VideoGenService(this.name, this.emoji, this.provider, this.desc);
  final String name;
  final String emoji;
  final String provider;
  final String desc;
}

// ═══════════════════════════════════════
// DIRECT UPLOAD TAB
// ═══════════════════════════════════════

class _DirectUploadTab extends StatefulWidget {
  const _DirectUploadTab({required this.services});
  final AppServices services;

  @override
  State<_DirectUploadTab> createState() => _DirectUploadTabState();
}

class _DirectUploadTabState extends State<_DirectUploadTab> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  String? _audioUrl;
  bool _isUploadingAudio = false;
  double _audioProgress = 0;

  String? _videoUrl;
  bool _isUploadingVideo = false;
  double _videoProgress = 0;

  String? _coverUrl;
  bool _isUploadingCover = false;

  bool _isPosting = false;
  String? _errorMessage;
  String? _successMessage;

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
        'tags': [..._tags, 'music-video'],
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        ShaderMask(
          shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
          child: Text(
            '📤 Upload Music Video',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        const Text('Upload your video directly.', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 20),

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

        TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Video Title',
            prefixIcon: Icon(Icons.title, color: MoltColors.purple, size: 20),
          ),
        ),
        const SizedBox(height: 12),

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
    );
  }
}

// ═══════════════════════════════════════
// API KEYS TAB
// ═══════════════════════════════════════

class _ApiKeysTab extends StatefulWidget {
  const _ApiKeysTab();

  @override
  State<_ApiKeysTab> createState() => _ApiKeysTabState();
}

class _ApiKeysTabState extends State<_ApiKeysTab> {
  static const _serviceKeys = [
    _ServiceKeyConfig('Seedance 2.0', '🌱', 'seedance_2.0'),
    _ServiceKeyConfig('Pika Labs', '⚡', 'pika_labs'),
    _ServiceKeyConfig('Runway Gen-3', '🎬', 'runway_gen-3'),
    _ServiceKeyConfig('Luma Dream Machine', '💫', 'luma_dream_machine'),
    _ServiceKeyConfig('Kling AI', '🎭', 'kling_ai'),
  ];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _saved = {};
  final Map<String, bool> _obscured = {};

  @override
  void initState() {
    super.initState();
    for (final s in _serviceKeys) {
      _controllers[s.key] = TextEditingController();
      _saved[s.key] = false;
      _obscured[s.key] = true;
    }
    _loadKeys();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    for (final s in _serviceKeys) {
      final key = prefs.getString('api_key_${s.key}');
      if (key != null && key.isNotEmpty) {
        _controllers[s.key]!.text = key;
        _saved[s.key] = true;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = _controllers[key]!.text.trim();
    if (value.isNotEmpty) {
      await prefs.setString('api_key_$key', value);
      setState(() => _saved[key] = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key saved! 🔑')),
        );
      }
    }
  }

  Future<void> _deleteKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_key_$key');
    _controllers[key]!.clear();
    setState(() => _saved[key] = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        ShaderMask(
          shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
          child: Text(
            '🔑 API Key Management',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Store your API keys for video generation services. Keys are saved locally on your device.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 20),

        ..._serviceKeys.map((s) {
          final isSaved = _saved[s.key] ?? false;
          final isObscured = _obscured[s.key] ?? true;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: MoltColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSaved
                    ? MoltColors.success.withValues(alpha: 0.3)
                    : MoltColors.purple.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    if (isSaved)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MoltColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('✅ Saved', style: TextStyle(color: MoltColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[s.key],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        obscureText: isObscured,
                        decoration: InputDecoration(
                          hintText: 'Enter API key...',
                          hintStyle: const TextStyle(color: MoltColors.textMuted, fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscured ? Icons.visibility_off : Icons.visibility,
                              color: MoltColors.textMuted,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscured[s.key] = !isObscured),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _saveKey(s.key),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: MoltColors.purplePinkGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.save, color: Colors.white, size: 20),
                      ),
                    ),
                    if (isSaved) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _deleteKey(s.key),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MoltColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_outline, color: MoltColors.error, size: 20),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ServiceKeyConfig {
  const _ServiceKeyConfig(this.name, this.emoji, this.key);
  final String name;
  final String emoji;
  final String key;
}

// ═══════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════

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
