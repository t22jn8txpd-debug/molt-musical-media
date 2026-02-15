import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

class LyricsWorkshopScreen extends StatefulWidget {
  const LyricsWorkshopScreen({super.key, this.services});

  final AppServices? services;

  @override
  State<LyricsWorkshopScreen> createState() => _LyricsWorkshopScreenState();
}

class _LyricsWorkshopScreenState extends State<LyricsWorkshopScreen> {
  final _lyricsController = TextEditingController();
  final _titleController = TextEditingController();
  final _aiPromptController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _genres = [
    'upbeat', 'dark', 'romantic', 'anime', 'hip-hop',
    'country', 'rock', 'pop', 'r&b', 'electronic',
    'jazz', 'lo-fi', 'metal', 'indie', 'soul', 'christian',
  ];

  final List<String> _moods = [
    'energetic', 'melancholic', 'dreamy', 'aggressive',
    'chill', 'euphoric', 'nostalgic', 'intense',
  ];

  final Set<String> _selectedGenres = {};
  String? _selectedMood;
  List<String> _savedDraftNames = [];
  int _templateIndex = -1;
  bool _isGeneratingLyrics = false;

  // 5 template types that cycle
  static const _templates = [
    // 0: Verse-Chorus
    '[Verse 1]\nWrite your opening verse here\nSet the scene and mood\n\n[Chorus]\nThe hook — catchy and memorable\nRepeat the main message\n\n[Verse 2]\nDevelop the story further\nAdd depth and emotion\n\n[Chorus]\nThe hook — catchy and memorable\nRepeat the main message\n\n[Bridge]\nA shift in perspective\nBuild to the final chorus\n\n[Chorus]\nThe hook — one last time\nLeave them wanting more\n',
    // 1: AABB Rhyme
    '[Verse 1 — AABB Rhyme]\nLine one sets the tone and starts the flow (A)\nLine two rhymes with one, lets the rhythm grow (A)\nLine three shifts the scene, a brand new sight (B)\nLine four matches three, everything feels right (B)\n\n[Verse 2 — AABB Rhyme]\nLine five takes it deeper, raise the stakes (A)\nLine six rhymes along, whatever it takes (A)\nLine seven brings the heat, turn up the fire (B)\nLine eight seals the deal, take it even higher (B)\n\n[Outro]\nClose it out with power\nEnd on a high note\n',
    // 2: Freestyle Flow
    '[Freestyle Flow]\nNo rules, just vibes\nLet the words pour out\nStream of consciousness\nSay what you feel\n\n[Build Up]\nRaise the energy\nStack the bars\nDouble-time if you want\nBend the rhythm\n\n[Drop]\nHit them with the punchline\nThe moment they remember\nMake it count\n',
    // 3: Storytelling
    '[Intro — Set the Scene]\nDescribe the time and place\nIntroduce the character\n\n[Verse 1 — The Setup]\nWhat happened first?\nPaint the picture with words\nMake the listener feel it\n\n[Verse 2 — The Conflict]\nWhat went wrong?\nThe turning point\nThe struggle, the pain\n\n[Verse 3 — The Resolution]\nHow does it end?\nThe lesson learned\nThe wisdom gained\n\n[Outro — Reflection]\nLook back on the journey\nLeave the listener thinking\n',
    // 4: Gospel/Worship
    '[Verse 1 — Praise]\nLift up your voice in worship\nDeclare His goodness and grace\n\n[Chorus — Declaration]\nHoly, holy is the Lord\nForever faithful, forever good\n\n[Verse 2 — Testimony]\nThrough the valleys and the storms\nHis love carried me through\n\n[Chorus — Declaration]\nHoly, holy is the Lord\nForever faithful, forever good\n\n[Bridge — Surrender]\nI lay it all down\nTake every part of me\n\n[Chorus — Declaration]\nHoly, holy is the Lord\nForever faithful, forever good\n',
  ];

  static const _templateNames = [
    'Verse-Chorus',
    'AABB Rhyme',
    'Freestyle Flow',
    'Storytelling',
    'Gospel/Worship',
  ];

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
    _aiPromptController.dispose();
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
    // Cycle to next template (replace entire content)
    _templateIndex = (_templateIndex + 1) % _templates.length;
    final template = _templates[_templateIndex];
    _lyricsController.text = template;
    _lyricsController.selection = TextSelection.collapsed(offset: template.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template: ${_templateNames[_templateIndex]}')),
    );
  }

  Future<void> _generateLyricsAI() async {
    final topic = _aiPromptController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a topic or prompt for AI lyrics')),
      );
      return;
    }

    setState(() => _isGeneratingLyrics = true);

    try {
      if (widget.services != null) {
        try {
          final response = await widget.services!.apiClient.dio.post(
            '/lyrics/generate',
            data: {
              'topic': topic,
              'genres': _selectedGenres.toList(),
              'mood': _selectedMood,
            },
          );
          final data = response.data;
          final lyrics = data['lyrics'] as String?;
          if (lyrics != null && lyrics.isNotEmpty) {
            setState(() => _lyricsController.text = lyrics);
            return;
          }
        } catch (_) {
          // Backend unavailable – use local generation
        }
      }

      // Local AI-like generation fallback
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      final genre = _selectedGenres.isNotEmpty ? _selectedGenres.first : 'pop';
      final mood = _selectedMood ?? 'energetic';
      final generated = _generateLocalLyrics(topic, genre, mood);
      setState(() => _lyricsController.text = generated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generation failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingLyrics = false);
    }
  }

  String _generateLocalLyrics(String topic, String genre, String mood) {
    return '[Verse 1]\n'
        'Writing about $topic, feeling the $mood vibe\n'
        'In this $genre world, where we come alive\n'
        'Every word we speak is a brand new line\n'
        'Every beat we drop is a sign of the time\n'
        '\n'
        '[Chorus]\n'
        '$topic on my mind, can\'t let it go\n'
        'The rhythm takes me places I want to know\n'
        '$topic in my heart, feel it in my soul\n'
        'This $genre sound is making me whole\n'
        '\n'
        '[Verse 2]\n'
        'From the highs to the lows, we ride the wave\n'
        'Every moment counts, every word we gave\n'
        'The $mood energy keeps us moving on\n'
        'Until the break of dawn, we carry on\n'
        '\n'
        '[Chorus]\n'
        '$topic on my mind, can\'t let it go\n'
        'The rhythm takes me places I want to know\n'
        '$topic in my heart, feel it in my soul\n'
        'This $genre sound is making me whole\n'
        '\n'
        '[Bridge]\n'
        'Let the music speak what words cannot say\n'
        'In this moment right here, we find our way\n'
        '\n'
        '[Chorus]\n'
        '$topic on my mind, can\'t let it go\n'
        'The rhythm takes me higher than before\n';
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
                  'Write, structure, and generate lyrics with AI.',
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
                  ],
                ),
                const SizedBox(height: 12),

                // AI Lyrics Generation
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
                        '🤖 AI Lyrics Generator',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _aiPromptController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Describe your song topic... e.g. "heartbreak in the city at night"',
                          hintStyle: TextStyle(color: MoltColors.textMuted, fontSize: 13),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GradientButton(
                        label: _isGeneratingLyrics ? 'Writing...' : '✨ Generate Lyrics',
                        icon: _isGeneratingLyrics ? null : Icons.auto_awesome,
                        onPressed: _isGeneratingLyrics ? null : _generateLyricsAI,
                        isLoading: _isGeneratingLyrics,
                        height: 42,
                      ),
                    ],
                  ),
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
