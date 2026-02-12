import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

class LyricsWorkshopScreen extends StatefulWidget {
  const LyricsWorkshopScreen({super.key});

  @override
  State<LyricsWorkshopScreen> createState() => _LyricsWorkshopScreenState();
}

class _LyricsWorkshopScreenState extends State<LyricsWorkshopScreen> {
  final _lyricsController = TextEditingController();
  final _titleController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _genres = [
    'upbeat', 'dark', 'romantic', 'anime', 'hip-hop',
    'country', 'rock', 'pop', 'r&b', 'electronic',
    'jazz', 'lo-fi', 'metal', 'indie', 'soul',
  ];

  final List<String> _moods = [
    'energetic', 'melancholic', 'dreamy', 'aggressive',
    'chill', 'euphoric', 'nostalgic', 'intense',
  ];

  final Set<String> _selectedGenres = {};
  String? _selectedMood;
  List<String> _savedDraftNames = [];
  bool _isLoadingDrafts = false;

  int get _wordCount {
    final text = _lyricsController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _lineCount {
    final text = _lyricsController.text;
    if (text.isEmpty) return 0;
    return text.split('\n').length;
  }

  int get _charCount => _lyricsController.text.length;

  @override
  void initState() {
    super.initState();
    _lyricsController.addListener(() => setState(() {}));
    _loadDraftNames();
  }

  @override
  void dispose() {
    _lyricsController.dispose();
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _countSyllables(String word) {
    word = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (word.isEmpty) return 0;
    int count = 0;
    bool prevVowel = false;
    for (int i = 0; i < word.length; i++) {
      final isVowel = 'aeiouy'.contains(word[i]);
      if (isVowel && !prevVowel) count++;
      prevVowel = isVowel;
    }
    if (word.endsWith('e') && count > 1) count--;
    return count < 1 ? 1 : count;
  }

  int _lineSyllables(String line) {
    return line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).fold(0, (sum, w) => sum + _countSyllables(w));
  }

  void _insertTemplate() {
    const template = '[Verse 1]\n\n\n[Chorus]\n\n\n[Verse 2]\n\n\n[Chorus]\n\n\n[Bridge]\n\n\n[Chorus]\n';
    final pos = _lyricsController.selection.baseOffset;
    final text = _lyricsController.text;
    if (pos >= 0) {
      _lyricsController.text = text.substring(0, pos) + template + text.substring(pos);
      _lyricsController.selection = TextSelection.collapsed(offset: pos + template.length);
    } else {
      _lyricsController.text = text + template;
    }
  }

  void _exportToSuno() {
    final genres = _selectedGenres.isNotEmpty ? _selectedGenres.join(', ') : 'pop';
    final mood = _selectedMood ?? 'energetic';
    final lyrics = _lyricsController.text.trim();
    if (lyrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write some lyrics first!')),
      );
      return;
    }
    final output = '[$genres] song, $mood, lyrics:\n$lyrics';
    Clipboard.setData(ClipboardData(text: output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard! 📋')),
    );
  }

  Future<void> _loadDraftNames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('lyric_draft_')).toList();
    setState(() => _savedDraftNames = keys.map((k) => k.replaceFirst('lyric_draft_', '')).toList()..sort());
  }

  Future<void> _saveDraft() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title to save.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'lyrics': _lyricsController.text,
      'genres': _selectedGenres.toList(),
      'mood': _selectedMood,
      'savedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString('lyric_draft_$title', data);
    await _loadDraftNames();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Draft "$title" saved! 💾')),
      );
    }
  }

  Future<void> _loadDraft(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('lyric_draft_$name');
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      _titleController.text = name;
      _lyricsController.text = data['lyrics'] as String? ?? '';
      _selectedGenres
        ..clear()
        ..addAll((data['genres'] as List?)?.cast<String>() ?? []);
      _selectedMood = data['mood'] as String?;
    });
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteDraft(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lyric_draft_$name');
    await _loadDraftNames();
  }

  void _showDraftsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MoltColors.dark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved Drafts',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              if (_savedDraftNames.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No drafts yet.', style: TextStyle(color: MoltColors.textMuted)),
                  ),
                )
              else
                ...List.generate(
                  _savedDraftNames.length > 10 ? 10 : _savedDraftNames.length,
                  (i) {
                    final name = _savedDraftNames[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description, color: MoltColors.purple),
                      title: Text(name, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: MoltColors.error, size: 20),
                        onPressed: () {
                          _deleteDraft(name);
                          Navigator.of(ctx).pop();
                          _showDraftsDialog();
                        },
                      ),
                      onTap: () => _loadDraft(name),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lyricsController.text.split('\n');

    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              children: [
                // Header
                ShaderMask(
                  shaderCallback: (bounds) => MoltColors.purplePinkGradient.createShader(bounds),
                  child: Text(
                    'Lyric Workshop ✍️',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Write, structure, and export your lyrics.',
                  style: TextStyle(color: MoltColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Title + Save/Load row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Draft Title',
                          prefixIcon: Icon(Icons.title, color: MoltColors.purple, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _saveDraft,
                      icon: const Icon(Icons.save, color: MoltColors.purple),
                      tooltip: 'Save Draft',
                    ),
                    IconButton(
                      onPressed: _showDraftsDialog,
                      icon: const Icon(Icons.folder_open, color: MoltColors.pink),
                      tooltip: 'Load Draft',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Genre chips
                Text('Genre', style: TextStyle(color: MoltColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _genres.map((g) {
                    final selected = _selectedGenres.contains(g);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedGenres.remove(g);
                        } else {
                          _selectedGenres.add(g);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? MoltColors.purple.withValues(alpha: 0.25) : MoltColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? MoltColors.purple : MoltColors.purple.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            color: selected ? MoltColors.purple : MoltColors.textMuted,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Mood selector
                Text('Mood', style: TextStyle(color: MoltColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _moods.map((m) {
                    final selected = _selectedMood == m;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = selected ? null : m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? MoltColors.pink.withValues(alpha: 0.25) : MoltColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? MoltColors.pink : MoltColors.pink.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            color: selected ? MoltColors.pink : MoltColors.textMuted,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Template',
                        icon: Icons.format_list_bulleted,
                        onPressed: _insertTemplate,
                        height: 40,
                        gradient: MoltColors.purpleBlueGradient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(
                        label: 'Export to Suno',
                        icon: Icons.copy,
                        onPressed: _exportToSuno,
                        height: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lyrics editor
                Container(
                  decoration: BoxDecoration(
                    gradient: MoltColors.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _lyricsController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15, height: 1.7),
                        maxLines: null,
                        minLines: 16,
                        decoration: const InputDecoration(
                          hintText: 'Start writing your lyrics...\n\n[Verse 1]\nYour words here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Syllable counts per line
                if (_lyricsController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MoltColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Syllables per line',
                          style: TextStyle(color: MoltColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        ...lines.asMap().entries
                            .where((e) => e.value.trim().isNotEmpty && !e.value.trim().startsWith('['))
                            .take(30)
                            .map((e) {
                          final syl = _lineSyllables(e.value);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '$syl',
                                    style: TextStyle(
                                      color: MoltColors.purple,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    e.value.trim(),
                                    style: TextStyle(color: MoltColors.textMuted, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: MoltColors.dark,
              border: Border(top: BorderSide(color: MoltColors.purple.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBadge(label: 'Words', value: _wordCount),
                _StatBadge(label: 'Lines', value: _lineCount),
                _StatBadge(label: 'Chars', value: _charCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: MoltColors.purple,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: MoltColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
