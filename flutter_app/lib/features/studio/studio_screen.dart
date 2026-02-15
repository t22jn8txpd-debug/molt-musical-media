import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';
import 'web_audio_helper.dart';
import 'web_mixer_helper.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key, this.services});

  final AppServices? services;

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> with SingleTickerProviderStateMixin {
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: MoltColors.purplePinkGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: MoltColors.purple.withValues(alpha: 0.4),
                          blurRadius: 20),
                    ],
                  ),
                  child: const Center(
                      child: Text('🎹', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            MoltColors.purplePinkGradient.createShader(b),
                        child: Text(
                          'Beat Maker Studio',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                      const Text('Create beats with AI + manual tools',
                          style: TextStyle(
                              color: MoltColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: MoltColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: MoltColors.purple.withValues(alpha: 0.2)),
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
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: '🤖 AI Generate'),
                Tab(text: '🎛️ Sequencer'),
                Tab(text: '🎚️ Mixer'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AIGenerateTab(services: widget.services),
                const _SequencerTab(),
                const _MixerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// AI GENERATE TAB
// ═══════════════════════════════════════

class _AIGenerateTab extends StatefulWidget {
  const _AIGenerateTab({this.services});
  final AppServices? services;

  @override
  State<_AIGenerateTab> createState() => _AIGenerateTabState();
}

class _AIGenerateTabState extends State<_AIGenerateTab> {
  final _promptController = TextEditingController();
  String _selectedGenre = 'Hip Hop';
  String _selectedMood = 'Energetic';
  double _bpm = 120;
  String _key = 'C minor';
  int _durationSec = 30;
  bool _instrumental = true;
  bool _isGenerating = false;
  String? _generatedUrl;
  String? _errorMessage;

  static const _genres = [
    'Hip Hop', 'Trap', 'R&B', 'Pop', 'Rock', 'Country', 'EDM',
    'Lo-Fi', 'Jazz', 'Anime/J-Pop', 'Metal', 'Soul', 'Indie',
    'Classical', 'Reggaeton', 'Afrobeats', 'Drill', 'Christian',
  ];

  static const _moods = [
    'Energetic', 'Chill', 'Dark', 'Upbeat', 'Melancholic',
    'Aggressive', 'Dreamy', 'Euphoric', 'Romantic', 'Epic',
  ];

  static const _keys = [
    'C major', 'C minor', 'D major', 'D minor', 'E major', 'E minor',
    'F major', 'F minor', 'G major', 'G minor', 'A major', 'A minor',
    'B major', 'B minor',
  ];

  String _buildPrompt() {
    final parts = <String>[];
    if (_promptController.text.trim().isNotEmpty) {
      parts.add(_promptController.text.trim());
    }
    parts.add('$_selectedGenre beat');
    parts.add('$_selectedMood mood');
    parts.add('${_bpm.round()} BPM');
    parts.add(_key);
    if (_instrumental) parts.add('instrumental');
    return parts.join(', ');
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedUrl = null;
    });

    try {
      if (widget.services != null) {
        try {
          final response = await widget.services!.apiClient.dio.post(
            '/generate/track',
            data: {
              'prompt': _buildPrompt(),
              'genre': _selectedGenre.toLowerCase(),
              'mood': _selectedMood.toLowerCase(),
              'duration_seconds': _durationSec,
              'instrumental': _instrumental,
            },
          );
          final data = response.data;
          final url = data['track']?['audioUrl'] as String?;
          if (url != null && url.isNotEmpty) {
            setState(() => _generatedUrl = url);
            return;
          }
        } catch (_) {
          // Backend unavailable – fall through to mock
        }
      }
      // Mock fallback: simulate generation with a placeholder
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _generatedUrl = 'mock://generated-beat';
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Generation failed. Try again or adjust your prompt.';
        });
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // Prompt input
        _StudioCard(
          title: '✨ Describe Your Beat',
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. "hard-hitting trap beat with 808 bass, dark vibes, hi-hats rolling..."',
                  hintStyle: TextStyle(color: MoltColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Genre + Mood row
        Row(
          children: [
            Expanded(
              child: _StudioCard(
                title: '🎵 Genre',
                compact: true,
                child: _ChipSelector(
                  items: _genres,
                  selected: _selectedGenre,
                  onSelected: (g) => setState(() => _selectedGenre = g),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StudioCard(
                title: '💫 Mood',
                compact: true,
                child: _ChipSelector(
                  items: _moods,
                  selected: _selectedMood,
                  onSelected: (m) => setState(() => _selectedMood = m),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // BPM, Key, Duration controls
        _StudioCard(
          title: '🎛️ Controls',
          child: Column(
            children: [
              // BPM
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('BPM',
                        style: GoogleFonts.inter(
                            color: MoltColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: MoltColors.purple,
                        inactiveTrackColor: MoltColors.surfaceLight,
                        thumbColor: MoltColors.purple,
                        overlayColor:
                            MoltColors.purple.withValues(alpha: 0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _bpm,
                        min: 60,
                        max: 200,
                        divisions: 140,
                        onChanged: (v) => setState(() => _bpm = v),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: MoltColors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_bpm.round()}',
                        style: const TextStyle(
                            color: MoltColors.purple,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Key + Duration row
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('Key',
                        style: GoogleFonts.inter(
                            color: MoltColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: MoltColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                MoltColors.purple.withValues(alpha: 0.2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _key,
                          dropdownColor: MoltColors.surface,
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: _keys
                              .map((k) => DropdownMenuItem(
                                  value: k, child: Text(k)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _key = v ?? _key),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text('Length',
                        style: GoogleFonts.inter(
                            color: MoltColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                  _DurationPill(
                    label: '15s',
                    selected: _durationSec == 15,
                    onTap: () => setState(() => _durationSec = 15),
                  ),
                  const SizedBox(width: 6),
                  _DurationPill(
                    label: '30s',
                    selected: _durationSec == 30,
                    onTap: () => setState(() => _durationSec = 30),
                  ),
                  const SizedBox(width: 6),
                  _DurationPill(
                    label: '60s',
                    selected: _durationSec == 60,
                    onTap: () => setState(() => _durationSec = 60),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Instrumental toggle
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text('Vocal',
                        style: GoogleFonts.inter(
                            color: MoltColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _instrumental = !_instrumental),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: _instrumental
                            ? MoltColors.purplePinkGradient
                            : null,
                        color: _instrumental ? null : MoltColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: _instrumental
                            ? null
                            : Border.all(
                                color: MoltColors.purple
                                    .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _instrumental ? '🎹 Instrumental' : '🎤 With Vocals',
                        style: TextStyle(
                          color: _instrumental
                              ? Colors.white
                              : MoltColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Prompt preview
        _StudioCard(
          title: '📋 Generated Prompt',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MoltColors.darker,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              _buildPrompt(),
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Error / Success
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MoltColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: MoltColors.error.withValues(alpha: 0.3)),
            ),
            child: Text(_errorMessage!,
                style: const TextStyle(
                    color: MoltColors.error, fontSize: 13)),
          ),

        if (_generatedUrl != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MoltColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: MoltColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: MoltColors.success, size: 20),
                    SizedBox(width: 8),
                    Text('Beat Generated! 🔥',
                        style: TextStyle(
                            color: MoltColors.success,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: '▶ Play',
                        icon: Icons.play_arrow,
                        onPressed: () {
                          // TODO: wire to audio player
                        },
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GradientButton(
                        label: '📤 Post Track',
                        icon: Icons.upload,
                        onPressed: () {
                          // TODO: navigate to create post with URL pre-filled
                        },
                        height: 40,
                        gradient: MoltColors.purpleBlueGradient,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Generate button
        GradientButton(
          label: _isGenerating ? 'Generating...' : '🔥 Generate Beat',
          icon: _isGenerating ? null : Icons.auto_awesome,
          onPressed: _isGenerating ? null : _generate,
          isLoading: _isGenerating,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Powered by MusicGen AI',
            style: TextStyle(color: MoltColors.textMuted, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// SEQUENCER TAB
// ═══════════════════════════════════════

class _SequencerTab extends StatefulWidget {
  const _SequencerTab();

  @override
  State<_SequencerTab> createState() => _SequencerTabState();
}

class _SequencerTabState extends State<_SequencerTab> {
  // 4 instruments × 16 steps
  static const _instruments = ['Kick', 'Snare', 'Hi-Hat', 'Clap'];
  static const _instrumentEmojis = ['🥁', '🪘', '🎩', '👏'];
  static const int _steps = 16;

  late List<List<bool>> _grid;
  int _currentStep = -1;
  Timer? _playTimer;
  bool _isPlaying = false;
  double _bpm = 120;
  WebAudioEngine? _audioEngine;

  @override
  void initState() {
    super.initState();
    _grid = List.generate(
        _instruments.length, (_) => List.generate(_steps, (_) => false));
    if (kIsWeb) {
      _audioEngine = WebAudioEngine();
    }
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _audioEngine?.dispose();
    super.dispose();
  }

  void _toggleCell(int instrument, int step) {
    setState(() => _grid[instrument][step] = !_grid[instrument][step]);
    // Play sound preview on toggle-on
    if (_grid[instrument][step]) {
      _audioEngine?.playInstrument(instrument);
    }
    HapticFeedback.lightImpact();
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _playTimer?.cancel();
      setState(() {
        _isPlaying = false;
        _currentStep = -1;
      });
    } else {
      setState(() => _isPlaying = true);
      final intervalMs = (60000 / _bpm / 4).round(); // 16th notes
      _playTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
        setState(() {
          _currentStep = (_currentStep + 1) % _steps;
        });
        // Trigger sounds for active cells at current step
        for (int i = 0; i < _grid.length; i++) {
          if (_grid[i][_currentStep]) {
            _audioEngine?.playInstrument(i);
          }
        }
      });
    }
  }

  void _clearGrid() {
    setState(() {
      for (var row in _grid) {
        for (int i = 0; i < row.length; i++) {
          row[i] = false;
        }
      }
    });
  }

  void _randomize() {
    final rng = Random();
    setState(() {
      for (int i = 0; i < _grid.length; i++) {
        for (int j = 0; j < _grid[i].length; j++) {
          // Different probabilities per instrument
          final prob = i == 0 ? 0.25 : i == 1 ? 0.15 : i == 2 ? 0.5 : 0.1;
          _grid[i][j] = rng.nextDouble() < prob;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      children: [
        // Transport controls
        _StudioCard(
          title: '▶ Transport',
          child: Row(
            children: [
              // Play/Stop
              GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isPlaying
                        ? const LinearGradient(
                            colors: [MoltColors.pink, MoltColors.error])
                        : MoltColors.purplePinkGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: MoltColors.purple.withValues(alpha: 0.4),
                          blurRadius: 16),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // BPM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BPM: ${_bpm.round()}',
                        style: const TextStyle(
                            color: MoltColors.textMuted, fontSize: 12)),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: MoltColors.purple,
                        inactiveTrackColor: MoltColors.surfaceLight,
                        thumbColor: MoltColors.purple,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _bpm,
                        min: 60,
                        max: 200,
                        onChanged: (v) => setState(() => _bpm = v),
                      ),
                    ),
                  ],
                ),
              ),
              // Clear & Randomize
              IconButton(
                icon: const Icon(Icons.casino, color: MoltColors.pink),
                tooltip: 'Randomize',
                onPressed: _randomize,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: MoltColors.textMuted),
                tooltip: 'Clear',
                onPressed: _clearGrid,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Step sequencer grid
        _StudioCard(
          title: '🎹 Step Sequencer',
          child: Column(
            children: [
              // Step numbers
              Row(
                children: [
                  const SizedBox(width: 56),
                  ...List.generate(_steps, (i) {
                    final isActive = _currentStep == i;
                    final isBeat = i % 4 == 0;
                    return Expanded(
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isActive
                                ? MoltColors.purple
                                : isBeat
                                    ? Colors.white54
                                    : Colors.white24,
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 6),
              // Grid rows
              ...List.generate(_instruments.length, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Row(
                          children: [
                            Text(_instrumentEmojis[row],
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _instruments[row],
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(_steps, (col) {
                        final active = _grid[row][col];
                        final isCurrent = _currentStep == col;
                        final isBeatStart = col % 4 == 0;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleCell(row, col),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              margin: const EdgeInsets.only(
                                  left: 1,
                                  right: 1),
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: active
                                    ? MoltColors.purplePinkGradient
                                    : null,
                                color: active
                                    ? null
                                    : isCurrent
                                        ? MoltColors.purple
                                            .withValues(alpha: 0.15)
                                        : isBeatStart
                                            ? MoltColors.surface
                                            : MoltColors.darker,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isCurrent
                                      ? MoltColors.purple
                                          .withValues(alpha: 0.6)
                                      : MoltColors.purple
                                          .withValues(alpha: 0.08),
                                  width: isCurrent ? 1.5 : 0.5,
                                ),
                                boxShadow: active && isCurrent
                                    ? [
                                        BoxShadow(
                                            color: MoltColors.purple
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8)
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Preset patterns
        _StudioCard(
          title: '🎯 Preset Patterns',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PresetChip(
                  label: '🔥 Trap',
                  onTap: () => _loadPreset(_trapPattern)),
              _PresetChip(
                  label: '🎤 Boom Bap',
                  onTap: () => _loadPreset(_boomBapPattern)),
              _PresetChip(
                  label: '🎸 Rock',
                  onTap: () => _loadPreset(_rockPattern)),
              _PresetChip(
                  label: '🎧 Hip-Hop',
                  onTap: () => _loadPreset(_hiphopPattern)),
              _PresetChip(
                  label: '⚡ EDM',
                  onTap: () => _loadPreset(_edmPattern)),
              _PresetChip(
                  label: '🎷 Jazz',
                  onTap: () => _loadPreset(_jazzPattern)),
              _PresetChip(
                  label: '💃 Latin',
                  onTap: () => _loadPreset(_latinPattern)),
              _PresetChip(
                  label: '🌊 Lo-Fi',
                  onTap: () => _loadPreset(_lofiPattern)),
              _PresetChip(
                  label: '👊 Drill',
                  onTap: () => _loadPreset(_drillPattern)),
              _PresetChip(
                  label: '🇵🇷 Reggaeton',
                  onTap: () => _loadPreset(_reggaetonPattern)),
              _PresetChip(
                  label: '✝️ Gospel',
                  onTap: () => _loadPreset(_gospelPattern)),
              _PresetChip(
                  label: '🤠 Country',
                  onTap: () => _loadPreset(_countryPattern)),
            ],
          ),
        ),
      ],
    );
  }

  void _loadPreset(List<List<bool>> pattern) {
    setState(() {
      for (int i = 0; i < _grid.length && i < pattern.length; i++) {
        for (int j = 0; j < _grid[i].length && j < pattern[i].length; j++) {
          _grid[i][j] = pattern[i][j];
        }
      }
    });
    HapticFeedback.mediumImpact();
  }

  // Preset patterns (Kick, Snare, Hi-Hat, Clap)
  static final _trapPattern = [
    [true, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
  ];

  static final _boomBapPattern = [
    [true, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
  ];

  static final _rockPattern = [
    [true, false, false, false, true, false, true, false, true, false, false, false, true, false, true, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
  ];

  static final _hiphopPattern = [
    [true, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, true],
    [false, false, false, false, true, false, false, true, false, false, false, false, true, false, false, false],
  ];

  static final _edmPattern = [
    [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, true],
  ];

  static final _jazzPattern = [
    [true, false, false, true, false, false, true, false, false, true, false, false, true, false, false, false],
    [false, false, false, false, false, true, false, false, false, false, false, true, false, false, true, false],
    [true, false, true, true, false, true, true, false, true, true, false, true, true, false, true, false],
    [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
  ];

  static final _latinPattern = [
    [true, false, false, true, false, false, true, false, false, false, true, false, true, false, false, false],
    [false, false, false, false, true, false, false, true, false, false, false, false, true, false, false, true],
    [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
    [false, false, true, false, false, true, false, false, true, false, false, true, false, false, true, false],
  ];

  static final _lofiPattern = [
    [true, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, true],
    [true, false, true, true, true, false, true, true, true, false, true, true, true, false, true, true],
    [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
  ];

  static final _drillPattern = [
    [true, false, false, true, false, false, false, false, true, false, false, true, false, false, true, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
    [false, false, false, false, true, false, false, true, false, false, false, false, true, false, false, true],
  ];

  static final _reggaetonPattern = [
    [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
    [false, false, false, true, false, false, true, false, false, false, false, true, false, false, true, false],
    [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
    [false, false, false, true, false, false, true, false, false, false, false, true, false, false, true, false],
  ];

  static final _gospelPattern = [
    [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
    [false, false, false, false, true, false, false, true, false, false, false, false, true, false, false, false],
    [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
    [false, false, false, false, true, false, false, false, false, false, true, false, true, false, false, true],
  ];

  static final _countryPattern = [
    [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
    [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
    [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
    [false, false, false, false, true, false, false, true, false, false, false, false, true, false, false, true],
  ];
}

// ═══════════════════════════════════════
// MIXER TAB
// ═══════════════════════════════════════

class _MixerTab extends StatefulWidget {
  const _MixerTab();

  @override
  State<_MixerTab> createState() => _MixerTabState();
}

class _MixerTabState extends State<_MixerTab> {
  final List<_MixChannel> _channels = [
    _MixChannel('Kick', '🥁', 0.8, 0.0, false, MoltColors.purple),
    _MixChannel('Snare', '🪘', 0.7, 0.0, false, MoltColors.pink),
    _MixChannel('Hi-Hat', '🎩', 0.6, 0.1, false, MoltColors.blue),
    _MixChannel('Clap', '👏', 0.5, -0.1, false, const Color(0xFF22D3EE)),
    _MixChannel('Bass', '🎸', 0.85, 0.0, false, MoltColors.purple),
    _MixChannel('Synth', '🎹', 0.6, 0.2, false, MoltColors.pink),
    _MixChannel('Vocal', '🎤', 0.75, 0.0, true, MoltColors.blue),
    _MixChannel('Master', '🎚️', 0.9, 0.0, false, Colors.amber),
  ];

  WebMixerEngine? _mixer;
  double _reverbWet = 0.0;
  double _delayWet = 0.0;
  double _delayTime = 0.3;
  double _eqLow = 0.0;
  double _eqMid = 0.0;
  double _eqHigh = 0.0;
  bool _reverbActive = false;
  bool _delayActive = false;
  bool _eqActive = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _mixer = WebMixerEngine();
    }
  }

  @override
  void dispose() {
    _mixer?.dispose();
    super.dispose();
  }

  void _onVolumeChanged(_MixChannel ch, double v) {
    setState(() => ch.volume = v);
    if (ch.name == 'Master') {
      _mixer?.setMasterVolume(v);
    } else {
      _mixer?.setVolume(ch.name, v);
    }
  }

  void _onMuteToggle(_MixChannel ch) {
    setState(() => ch.muted = !ch.muted);
    _mixer?.setMute(ch.name, ch.muted);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      children: [
        _StudioCard(
          title: '🎚️ Channel Mixer',
          child: Column(
            children: [
              SizedBox(
                height: 280,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _channels.map((ch) {
                    return Expanded(
                      child: _ChannelFader(
                        channel: ch,
                        onVolumeChanged: (v) => _onVolumeChanged(ch, v),
                        onPanChanged: (p) {
                          setState(() => ch.pan = p);
                          _mixer?.setPan(ch.name, p);
                        },
                        onMuteToggle: () => _onMuteToggle(ch),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Reverb
        _StudioCard(
          title: '🌊 Reverb',
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _reverbActive = !_reverbActive;
                        _reverbWet = _reverbActive ? 0.4 : 0.0;
                      });
                      _mixer?.setReverbWet(_reverbWet);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: _reverbActive ? MoltColors.purplePinkGradient : null,
                        color: _reverbActive ? null : MoltColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: _reverbActive ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _reverbActive ? 'ON' : 'OFF',
                        style: TextStyle(
                          color: _reverbActive ? Colors.white : MoltColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Wet', style: TextStyle(color: MoltColors.textMuted, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: MoltColors.purple,
                        inactiveTrackColor: MoltColors.surfaceLight,
                        thumbColor: MoltColors.purple,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _reverbWet,
                        onChanged: (v) {
                          setState(() => _reverbWet = v);
                          _mixer?.setReverbWet(v);
                        },
                      ),
                    ),
                  ),
                  Text('${(_reverbWet * 100).round()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Delay
        _StudioCard(
          title: '⏱️ Delay',
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _delayActive = !_delayActive;
                        _delayWet = _delayActive ? 0.3 : 0.0;
                      });
                      _mixer?.setDelayWet(_delayWet);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: _delayActive ? MoltColors.purplePinkGradient : null,
                        color: _delayActive ? null : MoltColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: _delayActive ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _delayActive ? 'ON' : 'OFF',
                        style: TextStyle(
                          color: _delayActive ? Colors.white : MoltColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Wet', style: TextStyle(color: MoltColors.textMuted, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: MoltColors.pink,
                        inactiveTrackColor: MoltColors.surfaceLight,
                        thumbColor: MoltColors.pink,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _delayWet,
                        onChanged: (v) {
                          setState(() => _delayWet = v);
                          _mixer?.setDelayWet(v);
                        },
                      ),
                    ),
                  ),
                  Text('${(_delayWet * 100).round()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 72),
                  const Text('Time', style: TextStyle(color: MoltColors.textMuted, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: MoltColors.pink,
                        inactiveTrackColor: MoltColors.surfaceLight,
                        thumbColor: MoltColors.pink,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _delayTime,
                        min: 0.05,
                        max: 1.5,
                        onChanged: (v) {
                          setState(() => _delayTime = v);
                          _mixer?.setDelayTime(v);
                        },
                      ),
                    ),
                  ),
                  Text('${(_delayTime * 1000).round()}ms', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // EQ
        _StudioCard(
          title: '📊 EQ',
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _eqActive = !_eqActive;
                        if (!_eqActive) {
                          _eqLow = 0; _eqMid = 0; _eqHigh = 0;
                          _mixer?.setEqLow(0);
                          _mixer?.setEqMid(0);
                          _mixer?.setEqHigh(0);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: _eqActive ? MoltColors.purplePinkGradient : null,
                        color: _eqActive ? null : MoltColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: _eqActive ? null : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _eqActive ? 'ON' : 'OFF',
                        style: TextStyle(
                          color: _eqActive ? Colors.white : MoltColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _eqSlider('Low (320Hz)', _eqLow, MoltColors.purple, (v) {
                setState(() => _eqLow = v);
                _mixer?.setEqLow(v);
              }),
              _eqSlider('Mid (1kHz)', _eqMid, MoltColors.pink, (v) {
                setState(() => _eqMid = v);
                _mixer?.setEqMid(v);
              }),
              _eqSlider('High (3.2kHz)', _eqHigh, MoltColors.blue, (v) {
                setState(() => _eqHigh = v);
                _mixer?.setEqHigh(v);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eqSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: MoltColors.textMuted, fontSize: 11)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: MoltColors.surfaceLight,
                thumbColor: color,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                min: -12,
                max: 12,
                onChanged: _eqActive ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${value >= 0 ? '+' : ''}${value.round()}dB',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _MixChannel {
  _MixChannel(
      this.name, this.emoji, this.volume, this.pan, this.muted, this.color);
  final String name;
  final String emoji;
  double volume;
  double pan;
  bool muted;
  final Color color;
}

class _ChannelFader extends StatelessWidget {
  const _ChannelFader({
    required this.channel,
    required this.onVolumeChanged,
    required this.onPanChanged,
    required this.onMuteToggle,
  });

  final _MixChannel channel;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onPanChanged;
  final VoidCallback onMuteToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Emoji
        Text(channel.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        // Volume fader (vertical)
        SizedBox(
          height: 160,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor:
                    channel.muted ? MoltColors.textMuted : channel.color,
                inactiveTrackColor: MoltColors.surfaceLight,
                thumbColor:
                    channel.muted ? MoltColors.textMuted : channel.color,
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: channel.volume,
                onChanged: onVolumeChanged,
              ),
            ),
          ),
        ),
        // Volume label
        Text(
          '${(channel.volume * 100).round()}%',
          style: TextStyle(
            color: channel.muted ? MoltColors.textMuted : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        // Mute button
        GestureDetector(
          onTap: onMuteToggle,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: channel.muted
                  ? MoltColors.error.withValues(alpha: 0.3)
                  : MoltColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: channel.muted
                    ? MoltColors.error
                    : MoltColors.purple.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(
                'M',
                style: TextStyle(
                  color:
                      channel.muted ? MoltColors.error : MoltColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Name
        Text(
          channel.name,
          style: const TextStyle(color: Colors.white54, fontSize: 9),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════

class _StudioCard extends StatelessWidget {
  const _StudioCard(
      {required this.title, required this.child, this.compact = false});
  final String title;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: MoltColors.purple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          child,
        ],
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector(
      {required this.items,
      required this.selected,
      required this.onSelected});
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            final isSelected = item == selected;
            return GestureDetector(
              onTap: () => onSelected(item),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected ? MoltColors.purplePinkGradient : null,
                  color: isSelected ? null : MoltColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(
                          color:
                              MoltColors.purple.withValues(alpha: 0.2)),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MoltColors.textMuted,
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? MoltColors.purplePinkGradient : null,
          color: selected ? null : MoltColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? null
              : Border.all(
                  color: MoltColors.purple.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : MoltColors.textMuted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: MoltColors.surface,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: MoltColors.purple.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  const _EffectChip({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: active ? MoltColors.purplePinkGradient : null,
        color: active ? null : MoltColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: active
            ? null
            : Border.all(
                color: MoltColors.purple.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : MoltColors.textMuted,
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
