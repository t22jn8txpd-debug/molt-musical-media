'use client'

import { useState, useEffect, useRef } from 'react'
import * as Tone from 'tone'

type Track = {
  id: string
  name: string
  type: 'drums' | 'bass' | 'melody' | 'vocals'
  volume: number
  muted: boolean
  solo: boolean
  pattern: boolean[]
  instrument: any
}

type Genre = {
  name: string
  bpm: number
  key: string
  emoji: string
}

const GENRES: Genre[] = [
  { name: 'Hip Hop', bpm: 90, key: 'Am', emoji: '🎤' },
  { name: 'Trap', bpm: 140, key: 'C#m', emoji: '🔥' },
  { name: 'R&B', bpm: 75, key: 'Dm', emoji: '💜' },
  { name: 'Pop', bpm: 120, key: 'C', emoji: '✨' },
  { name: 'Rock', bpm: 110, key: 'E', emoji: '🎸' },
  { name: 'Country', bpm: 95, key: 'G', emoji: '🤠' },
  { name: 'EDM', bpm: 128, key: 'Am', emoji: '⚡' },
]

export default function Studio() {
  const [isPlaying, setIsPlaying] = useState(false)
  const [bpm, setBpm] = useState(120)
  const [selectedGenre, setSelectedGenre] = useState<Genre>(GENRES[0])
  const [currentStep, setCurrentStep] = useState(0)
  const [tracks, setTracks] = useState<Track[]>([])
  const [toneStarted, setToneStarted] = useState(false)

  const sequenceRef = useRef<any>(null)

  useEffect(() => {
    // Initialize default tracks
    initializeTracks()
  }, [])

  useEffect(() => {
    if (toneStarted) {
      Tone.Transport.bpm.value = bpm
    }
  }, [bpm, toneStarted])

  const initializeTracks = () => {
    const defaultTracks: Track[] = [
      {
        id: 'kick',
        name: 'Kick',
        type: 'drums',
        volume: 0,
        muted: false,
        solo: false,
        pattern: Array(16).fill(false),
        instrument: new Tone.MembraneSynth().toDestination()
      },
      {
        id: 'snare',
        name: 'Snare',
        type: 'drums',
        volume: 0,
        muted: false,
        solo: false,
        pattern: Array(16).fill(false),
        instrument: new Tone.NoiseSynth({
          noise: { type: 'white' },
          envelope: { attack: 0.005, decay: 0.1, sustain: 0 }
        }).toDestination()
      },
      {
        id: 'hihat',
        name: 'Hi-Hat',
        type: 'drums',
        volume: -6,
        muted: false,
        solo: false,
        pattern: Array(16).fill(false),
        instrument: new Tone.MetalSynth({
          frequency: 200,
          envelope: { attack: 0.001, decay: 0.1, release: 0.01 },
          harmonicity: 5.1,
          modulationIndex: 32,
          resonance: 4000,
          octaves: 1.5
        }).toDestination()
      },
      {
        id: 'bass',
        name: 'Bass',
        type: 'bass',
        volume: 0,
        muted: false,
        solo: false,
        pattern: Array(16).fill(false),
        instrument: new Tone.Synth({
          oscillator: { type: 'sine' },
          envelope: { attack: 0.01, decay: 0.2, sustain: 0.5, release: 0.3 }
        }).toDestination()
      }
    ]
    setTracks(defaultTracks)
  }

  const startTone = async () => {
    if (!toneStarted) {
      await Tone.start()
      Tone.Transport.bpm.value = bpm
      setToneStarted(true)
    }
  }

  const togglePlay = async () => {
    await startTone()

    if (!isPlaying) {
      // Clear existing sequence if any
      if (sequenceRef.current) {
        sequenceRef.current.dispose()
      }

      // Create new sequence
      sequenceRef.current = new Tone.Sequence(
        (time, step) => {
          setCurrentStep(step)
          
          tracks.forEach(track => {
            if (!track.muted && track.pattern[step]) {
              if (track.type === 'drums') {
                if (track.id === 'kick') {
                  track.instrument.triggerAttackRelease('C1', '8n', time)
                } else if (track.id === 'snare') {
                  track.instrument.triggerAttackRelease('8n', time)
                } else if (track.id === 'hihat') {
                  track.instrument.triggerAttackRelease('16n', time)
                }
              } else if (track.type === 'bass') {
                track.instrument.triggerAttackRelease('A1', '8n', time)
              }
            }
          })
        },
        [...Array(16).keys()],
        '16n'
      )

      sequenceRef.current.start(0)
      Tone.Transport.start()
      setIsPlaying(true)
    } else {
      Tone.Transport.stop()
      if (sequenceRef.current) {
        sequenceRef.current.stop()
      }
      setIsPlaying(false)
      setCurrentStep(0)
    }
  }

  const toggleStep = (trackId: string, stepIndex: number) => {
    setTracks(tracks.map(track => {
      if (track.id === trackId) {
        const newPattern = [...track.pattern]
        newPattern[stepIndex] = !newPattern[stepIndex]
        return { ...track, pattern: newPattern }
      }
      return track
    }))
  }

  const toggleMute = (trackId: string) => {
    setTracks(tracks.map(track => {
      if (track.id === trackId) {
        return { ...track, muted: !track.muted }
      }
      return track
    }))
  }

  const clearTrack = (trackId: string) => {
    setTracks(tracks.map(track => {
      if (track.id === trackId) {
        return { ...track, pattern: Array(16).fill(false) }
      }
      return track
    }))
  }

  const loadGenreTemplate = (genre: Genre) => {
    setSelectedGenre(genre)
    setBpm(genre.bpm)

    // Load genre-specific patterns
    const templates: any = {
      'Hip Hop': {
        kick: [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
        snare: [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
        hihat: [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false]
      },
      'Trap': {
        kick: [true, false, false, true, false, false, true, false, false, true, false, false, true, false, false, false],
        snare: [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false],
        hihat: [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
      },
      'Rock': {
        kick: [true, false, false, false, true, false, true, false, true, false, false, false, true, false, true, false],
        snare: [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false],
        hihat: [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
      }
    }

    const template = templates[genre.name] || templates['Hip Hop']

    setTracks(tracks.map(track => {
      if (template[track.id]) {
        return { ...track, pattern: template[track.id] }
      }
      return track
    }))
  }

  const exportBeat = () => {
    // TODO: Implement actual export with Tone.js Recorder
    alert('Export feature coming soon! Your beat will be saved as WAV/MP3.')
  }

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-4 bg-gradient-to-r from-molt-purple to-molt-pink bg-clip-text text-transparent">
            🎹 Beat Maker Studio
          </h1>
          <p className="text-gray-400">Create professional beats across multiple genres</p>
        </div>

        {/* Controls */}
        <div className="bg-molt-dark rounded-xl p-6 mb-6 border border-molt-purple/20">
          <div className="grid md:grid-cols-4 gap-6">
            {/* Play/Stop */}
            <div>
              <label className="block text-sm text-gray-400 mb-2">Playback</label>
              <button
                onClick={togglePlay}
                className={`w-full px-6 py-3 rounded-lg font-bold transition ${
                  isPlaying 
                    ? 'bg-red-500 hover:bg-red-600' 
                    : 'bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90'
                }`}
              >
                {isPlaying ? '⏸ Stop' : '▶ Play'}
              </button>
            </div>

            {/* BPM */}
            <div>
              <label className="block text-sm text-gray-400 mb-2">BPM: {bpm}</label>
              <input
                type="range"
                min="60"
                max="180"
                value={bpm}
                onChange={(e) => setBpm(Number(e.target.value))}
                className="w-full h-3 bg-molt-darker rounded-lg appearance-none cursor-pointer"
              />
            </div>

            {/* Key */}
            <div>
              <label className="block text-sm text-gray-400 mb-2">Key</label>
              <select 
                value={selectedGenre.key}
                className="w-full px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
              >
                <option>Am</option>
                <option>C</option>
                <option>C#m</option>
                <option>Dm</option>
                <option>E</option>
                <option>G</option>
              </select>
            </div>

            {/* Export */}
            <div>
              <label className="block text-sm text-gray-400 mb-2">Export</label>
              <button
                onClick={exportBeat}
                className="w-full px-6 py-3 rounded-lg bg-molt-blue hover:bg-molt-blue/80 font-bold transition"
              >
                💾 Export Beat
              </button>
            </div>
          </div>
        </div>

        {/* Genre Templates */}
        <div className="bg-molt-dark rounded-xl p-6 mb-6 border border-molt-purple/20">
          <h3 className="text-lg font-bold mb-4">Genre Templates</h3>
          <div className="flex flex-wrap gap-3">
            {GENRES.map(genre => (
              <button
                key={genre.name}
                onClick={() => loadGenreTemplate(genre)}
                className={`px-4 py-2 rounded-lg font-bold transition ${
                  selectedGenre.name === genre.name
                    ? 'bg-gradient-to-r from-molt-purple to-molt-pink'
                    : 'bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20'
                }`}
              >
                {genre.emoji} {genre.name}
              </button>
            ))}
          </div>
        </div>

        {/* Sequencer */}
        <div className="bg-molt-dark rounded-xl p-6 border border-molt-purple/20">
          <h3 className="text-lg font-bold mb-4">16-Step Sequencer</h3>
          
          {tracks.map(track => (
            <div key={track.id} className="mb-4">
              <div className="flex items-center gap-4 mb-2">
                <div className="w-24 font-bold text-sm">{track.name}</div>
                <button
                  onClick={() => toggleMute(track.id)}
                  className={`px-3 py-1 rounded text-xs font-bold ${
                    track.muted ? 'bg-red-500' : 'bg-molt-darker'
                  }`}
                >
                  {track.muted ? 'M' : 'M'}
                </button>
                <button
                  onClick={() => clearTrack(track.id)}
                  className="px-3 py-1 rounded text-xs font-bold bg-molt-darker hover:bg-molt-darker/50"
                >
                  Clear
                </button>
              </div>
              
              <div className="flex gap-1">
                {track.pattern.map((active, stepIndex) => (
                  <button
                    key={stepIndex}
                    onClick={() => toggleStep(track.id, stepIndex)}
                    className={`flex-1 h-12 rounded transition ${
                      active
                        ? 'bg-gradient-to-br from-molt-purple to-molt-pink'
                        : 'bg-molt-darker hover:bg-molt-darker/50'
                    } ${
                      stepIndex === currentStep && isPlaying
                        ? 'ring-2 ring-white'
                        : ''
                    }`}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Info */}
        <div className="mt-6 p-4 bg-molt-purple/10 rounded-lg border border-molt-purple/20">
          <p className="text-sm text-gray-400">
            💡 <strong>Tip:</strong> Click the step buttons to add/remove sounds. Load a genre template to get started quickly!
          </p>
        </div>
      </div>
    </div>
  )
}
