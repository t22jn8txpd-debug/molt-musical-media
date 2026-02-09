import 'package:flutter/material.dart';

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
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentUrlController.dispose();
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
      await widget.services.apiClient.dio.post('/posts', data: {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'content_url': _contentUrlController.text.trim(),
        'content_type': _contentType,
        'tags': _tags,
      });

      setState(() {
        _successMessage = 'Track posted successfully! 🔥';
        _titleController.clear();
        _descriptionController.clear();
        _contentUrlController.clear();
        _tags.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to post. Check your inputs and try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              'Drop a Track 🎵',
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
