'use client'

import { useState } from 'react'

type LyricSection = {
  id: string
  type: 'verse' | 'chorus' | 'bridge' | 'hook'
  content: string
}

const RHYME_SUGGESTIONS: { [key: string]: string[] } = {
  'fly': ['high', 'sky', 'try', 'die', 'why', 'buy', 'lie', 'spy'],
  'beat': ['heat', 'street', 'meet', 'neat', 'feet', 'seat', 'sweet', 'treat'],
  'flow': ['go', 'show', 'know', 'glow', 'slow', 'grow', 'throw', 'below'],
  'game': ['fame', 'name', 'claim', 'shame', 'flame', 'frame', 'same', 'tame']
}

const GENRE_PROMPTS = {
  'Hip Hop': 'Write bars about success, hustle, and making it from the bottom',
  'R&B': 'Craft smooth verses about love, relationships, and emotions',
  'Pop': 'Create catchy hooks and verses about life, love, and good times',
  'Rock': 'Write powerful lyrics about rebellion, passion, and freedom',
  'Country': 'Tell stories about life, home, and heartfelt moments'
}

export default function LyricsWorkshop() {
  const [sections, setSections] = useState<LyricSection[]>([
    { id: '1', type: 'verse', content: '' }
  ])
  const [selectedGenre, setSelectedGenre] = useState('Hip Hop')
  const [currentWord, setCurrentWord] = useState('')
  const [rhymes, setRhymes] = useState<string[]>([])
  const [aiPrompt, setAiPrompt] = useState('')
  const [generatedLyrics, setGeneratedLyrics] = useState('')

  const addSection = (type: LyricSection['type']) => {
    const newSection: LyricSection = {
      id: Date.now().toString(),
      type,
      content: ''
    }
    setSections([...sections, newSection])
  }

  const updateSection = (id: string, content: string) => {
    setSections(sections.map(section => 
      section.id === id ? { ...section, content } : section
    ))
  }

  const deleteSection = (id: string) => {
    setSections(sections.filter(section => section.id !== id))
  }

  const findRhymes = (word: string) => {
    setCurrentWord(word)
    const lastThreeChars = word.toLowerCase().slice(-3)
    const matches = RHYME_SUGGESTIONS[word.toLowerCase()] || []
    
    // Simplified rhyme finding - in production, use a real rhyme API
    setRhymes(matches.length > 0 ? matches : ['No rhymes found'])
  }

  const countSyllables = (text: string): number => {
    // Simplified syllable counter
    const words = text.toLowerCase().match(/[a-z]+/g) || []
    return words.reduce((count, word) => {
      return count + Math.max(1, word.match(/[aeiouy]+/g)?.length || 1)
    }, 0)
  }

  const generateAILyrics = async () => {
    // Simulate AI generation - in production, call actual LLM API
    setGeneratedLyrics('Generating lyrics...')
    
    setTimeout(() => {
      const mockLyrics = `[Verse 1]
Started from the bottom, now I'm on my grind
Every single day I'm working, staying on my mind
Got that vision clear, yeah I'm one of a kind
Success is in my future, leaving doubts behind

[Chorus]
We rising to the top, ain't no stopping now
Built this from the ground, let me show you how
Every move I make, every single vow
Making history, take a look at us now

[Verse 2]
Late nights, early mornings, that's the sacrifice
Focused on the mission, rolling all the dice
Every lesson learned comes with its own price
But when you reach the summit, yeah it's paradise`

      setGeneratedLyrics(mockLyrics)
    }, 2000)
  }

  const exportLyrics = () => {
    const fullText = sections.map(section => 
      `[${section.type.toUpperCase()}]\n${section.content}\n`
    ).join('\n')
    
    const blob = new Blob([fullText], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'lyrics.txt'
    a.click()
  }

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-4 bg-gradient-to-r from-molt-purple to-molt-pink bg-clip-text text-transparent">
            ✍️ Lyric Workshop
          </h1>
          <p className="text-gray-400">Write and refine your lyrics with AI assistance</p>
        </div>

        <div className="grid lg:grid-cols-3 gap-6">
          {/* Main Editor */}
          <div className="lg:col-span-2 space-y-4">
            {/* Controls */}
            <div className="bg-molt-dark rounded-xl p-4 border border-molt-purple/20">
              <div className="flex flex-wrap gap-3">
                <button
                  onClick={() => addSection('verse')}
                  className="px-4 py-2 rounded-lg bg-molt-purple hover:bg-molt-purple/80 font-bold"
                >
                  + Verse
                </button>
                <button
                  onClick={() => addSection('chorus')}
                  className="px-4 py-2 rounded-lg bg-molt-pink hover:bg-molt-pink/80 font-bold"
                >
                  + Chorus
                </button>
                <button
                  onClick={() => addSection('bridge')}
                  className="px-4 py-2 rounded-lg bg-molt-blue hover:bg-molt-blue/80 font-bold"
                >
                  + Bridge
                </button>
                <button
                  onClick={() => addSection('hook')}
                  className="px-4 py-2 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold"
                >
                  + Hook
                </button>
                <button
                  onClick={exportLyrics}
                  className="ml-auto px-4 py-2 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold"
                >
                  💾 Export
                </button>
              </div>
            </div>

            {/* Sections */}
            {sections.map(section => (
              <div key={section.id} className="bg-molt-dark rounded-xl p-6 border border-molt-purple/20">
                <div className="flex justify-between items-center mb-3">
                  <div className="flex items-center gap-3">
                    <span className="px-3 py-1 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink text-sm font-bold">
                      {section.type.toUpperCase()}
                    </span>
                    <span className="text-sm text-gray-400">
                      {countSyllables(section.content)} syllables
                    </span>
                  </div>
                  <button
                    onClick={() => deleteSection(section.id)}
                    className="px-3 py-1 rounded-lg bg-red-500/20 hover:bg-red-500/30 text-red-400 text-sm font-bold"
                  >
                    Delete
                  </button>
                </div>
                <textarea
                  value={section.content}
                  onChange={(e) => updateSection(section.id, e.target.value)}
                  placeholder={`Write your ${section.type} here...`}
                  className="w-full h-32 bg-molt-darker rounded-lg p-4 text-white outline-none border border-molt-purple/20 focus:border-molt-purple resize-none"
                />
              </div>
            ))}

            {sections.length === 0 && (
              <div className="bg-molt-dark rounded-xl p-12 border border-molt-purple/20 text-center">
                <p className="text-gray-400 mb-4">No sections yet. Start by adding a verse or chorus!</p>
                <button
                  onClick={() => addSection('verse')}
                  className="px-6 py-3 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold"
                >
                  + Add First Section
                </button>
              </div>
            )}
          </div>

          {/* Sidebar Tools */}
          <div className="space-y-4">
            {/* Genre Selection */}
            <div className="bg-molt-dark rounded-xl p-4 border border-molt-purple/20">
              <h3 className="font-bold mb-3">Genre</h3>
              <select
                value={selectedGenre}
                onChange={(e) => setSelectedGenre(e.target.value)}
                className="w-full px-4 py-2 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
              >
                {Object.keys(GENRE_PROMPTS).map(genre => (
                  <option key={genre} value={genre}>{genre}</option>
                ))}
              </select>
            </div>

            {/* AI Generator */}
            <div className="bg-molt-dark rounded-xl p-4 border border-molt-purple/20">
              <h3 className="font-bold mb-3">🤖 AI Lyric Generator</h3>
              <p className="text-xs text-gray-400 mb-3">
                {GENRE_PROMPTS[selectedGenre as keyof typeof GENRE_PROMPTS]}
              </p>
              <textarea
                value={aiPrompt}
                onChange={(e) => setAiPrompt(e.target.value)}
                placeholder="Describe what you want... (e.g., 'a verse about overcoming struggles')"
                className="w-full h-20 bg-molt-darker rounded-lg p-3 text-sm text-white outline-none border border-molt-purple/20 focus:border-molt-purple resize-none mb-3"
              />
              <button
                onClick={generateAILyrics}
                className="w-full px-4 py-2 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold"
              >
                Generate Lyrics
              </button>
              
              {generatedLyrics && (
                <div className="mt-3 p-3 bg-molt-darker rounded-lg text-xs whitespace-pre-wrap">
                  {generatedLyrics}
                </div>
              )}
            </div>

            {/* Rhyme Finder */}
            <div className="bg-molt-dark rounded-xl p-4 border border-molt-purple/20">
              <h3 className="font-bold mb-3">🎯 Rhyme Finder</h3>
              <input
                type="text"
                value={currentWord}
                onChange={(e) => findRhymes(e.target.value)}
                placeholder="Enter a word..."
                className="w-full px-4 py-2 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none mb-3"
              />
              {rhymes.length > 0 && (
                <div className="flex flex-wrap gap-2">
                  {rhymes.map((rhyme, i) => (
                    <span
                      key={i}
                      className="px-3 py-1 bg-molt-purple/20 rounded-lg text-sm cursor-pointer hover:bg-molt-purple/30"
                    >
                      {rhyme}
                    </span>
                  ))}
                </div>
              )}
            </div>

            {/* Quick Tips */}
            <div className="bg-molt-purple/10 rounded-xl p-4 border border-molt-purple/20">
              <h3 className="font-bold mb-2">💡 Quick Tips</h3>
              <ul className="text-xs text-gray-400 space-y-1">
                <li>• Keep verses 4-8 lines</li>
                <li>• Choruses should be catchy & repetitive</li>
                <li>• Use rhyme schemes (AABB, ABAB)</li>
                <li>• Vary syllable count for flow</li>
                <li>• Bridge adds contrast</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
