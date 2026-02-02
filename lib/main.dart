import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MoltMusicalMedia());
}

class MoltMusicalMedia extends StatelessWidget {
  const MoltMusicalMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOLT MUSICAL MEDIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        cardColor: const Color(0xFF16213e),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BeatMakerPage(),
    const DiscoveryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🎵 ', style: TextStyle(fontSize: 24)),
            Text(
              'MOLT MUSICAL MEDIA',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF16213e),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Beat Maker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// BEAT MAKER PAGE - Core POC Feature
class BeatMakerPage extends StatefulWidget {
  const BeatMakerPage({super.key});

  @override
  State<BeatMakerPage> createState() => _BeatMakerPageState();
}

class _BeatMakerPageState extends State<BeatMakerPage> {
  double bpm = 120;
  String selectedGenre = 'Hip Hop';
  final List<String> genres = ['Hip Hop', 'R&B', 'Pop', 'Rock', 'Country', 'Lofi'];
  
  // 8 tracks, 16 steps each
  List<List<bool>> beatGrid = List.generate(8, (_) => List.filled(16, false));
  final List<String> trackNames = [
    'Kick',
    'Snare',
    'Hi-Hat',
    'Clap',
    'Bass',
    'Melody 1',
    'Melody 2',
    'FX',
  ];

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Create Your Beat 🎵',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Controls
          Row(
            children: [
              // Genre Selector
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6C63FF)),
                  ),
                  child: DropdownButton<String>(
                    value: selectedGenre,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF16213e),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: genres.map((genre) {
                      return DropdownMenuItem(value: genre, child: Text(genre));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedGenre = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // BPM Control
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BPM: ${bpm.toInt()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: bpm,
                      min: 60,
                      max: 180,
                      divisions: 120,
                      activeColor: const Color(0xFF6C63FF),
                      onChanged: (value) => setState(() => bpm = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Beat Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header row (step numbers)
                Row(
                  children: [
                    const SizedBox(width: 80),
                    ...List.generate(16, (step) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            '${step + 1}',
                            style: TextStyle(
                              color: step % 4 == 0 ? const Color(0xFF6C63FF) : Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Track rows
                ...List.generate(8, (track) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Track name
                        SizedBox(
                          width: 80,
                          child: Text(
                            trackNames[track],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        // Beat steps
                        ...List.generate(16, (step) {
                          final isActive = beatGrid[track][step];
                          final isDownbeat = step % 4 == 0;
                          
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  beatGrid[track][step] = !beatGrid[track][step];
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF6C63FF)
                                      : isDownbeat
                                          ? const Color(0xFF2a2d3e)
                                          : const Color(0xFF1e2130),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isDownbeat
                                        ? const Color(0xFF6C63FF).withAlpha(76)
                                        : Colors.transparent,
                                  ),
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
          const SizedBox(height: 24),
          
          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => isPlaying = !isPlaying);
                  // TODO: Implement audio playback
                },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? 'Pause' : 'Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              
              // Clear
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    beatGrid = List.generate(8, (_) => List.filled(16, false));
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Export Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Save to profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Beat saved to profile! 🔥')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Export WAV
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting WAV... 🎵')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Export'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// DISCOVERY PAGE - Placeholder
class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.explore, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Discover',
            style: GoogleFonts.inter(fontSize: 24, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// PROFILE PAGE - Placeholder
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Profile',
            style: GoogleFonts.inter(fontSize: 24, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
