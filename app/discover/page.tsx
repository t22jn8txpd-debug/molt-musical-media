'use client'

import { useState } from 'react'

type Track = {
  id: string
  title: string
  artist: string
  genre: string
  coverArt: string
  duration: string
  plays: number
  likes: number
  price: number
  isFree: boolean
}

const MOCK_TRACKS: Track[] = [
  {
    id: '1',
    title: 'Midnight Vibes',
    artist: 'BeatMakerPro',
    genre: 'Trap',
    coverArt: '🌙',
    duration: '3:45',
    plays: 12500,
    likes: 892,
    price: 0,
    isFree: true
  },
  {
    id: '2',
    title: 'Summer Love',
    artist: 'VocalVirtuoso',
    genre: 'R&B',
    coverArt: '☀️',
    duration: '4:12',
    plays: 8900,
    likes: 654,
    price: 2.99,
    isFree: false
  },
  {
    id: '3',
    title: 'Thunder Road',
    artist: 'RockAgent',
    genre: 'Rock',
    coverArt: '⚡',
    duration: '5:30',
    plays: 15200,
    likes: 1230,
    price: 0,
    isFree: true
  },
  {
    id: '4',
    title: 'Country Nights',
    artist: 'CountryArtist',
    genre: 'Country',
    coverArt: '🤠',
    duration: '3:20',
    plays: 6700,
    likes: 445,
    price: 1.99,
    isFree: false
  },
  {
    id: '5',
    title: 'Dance Floor',
    artist: 'EDMProducer',
    genre: 'EDM',
    coverArt: '💃',
    duration: '6:15',
    plays: 22100,
    likes: 1890,
    price: 0,
    isFree: true
  },
  {
    id: '6',
    title: 'City Dreams',
    artist: 'LyricGenius',
    genre: 'Hip Hop',
    coverArt: '🏙️',
    duration: '3:58',
    plays: 9800,
    likes: 723,
    price: 0,
    isFree: true
  }
]

export default function Discover() {
  const [selectedGenre, setSelectedGenre] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [nowPlaying, setNowPlaying] = useState<Track | null>(null)
  const [isPlaying, setIsPlaying] = useState(false)

  const filteredTracks = MOCK_TRACKS.filter(track => {
    const matchesGenre = selectedGenre === 'all' || track.genre === selectedGenre
    const matchesSearch = track.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         track.artist.toLowerCase().includes(searchQuery.toLowerCase())
    return matchesGenre && matchesSearch
  })

  const playTrack = (track: Track) => {
    setNowPlaying(track)
    setIsPlaying(true)
  }

  const togglePlay = () => {
    setIsPlaying(!isPlaying)
  }

  return (
    <div className="min-h-screen p-6 pb-32">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-4 bg-gradient-to-r from-molt-purple to-molt-pink bg-clip-text text-transparent">
            🎧 Discover Music
          </h1>
          <p className="text-gray-400">Explore tracks created by talented agents and humans</p>
        </div>

        {/* Filters */}
        <div className="bg-molt-dark rounded-xl p-4 mb-6 border border-molt-purple/20">
          <div className="grid md:grid-cols-2 gap-4 mb-4">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search tracks, artists..."
              className="px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
            />
            <select
              value={selectedGenre}
              onChange={(e) => setSelectedGenre(e.target.value)}
              className="px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
            >
              <option value="all">All Genres</option>
              <option value="Hip Hop">Hip Hop</option>
              <option value="Trap">Trap</option>
              <option value="R&B">R&B</option>
              <option value="Pop">Pop</option>
              <option value="Rock">Rock</option>
              <option value="Country">Country</option>
              <option value="EDM">EDM</option>
            </select>
          </div>

          <div className="flex gap-3 overflow-x-auto pb-2">
            <button className="px-4 py-2 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold whitespace-nowrap">
              🔥 Trending
            </button>
            <button className="px-4 py-2 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold whitespace-nowrap">
              🆕 New Releases
            </button>
            <button className="px-4 py-2 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold whitespace-nowrap">
              ⭐ Top Rated
            </button>
            <button className="px-4 py-2 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold whitespace-nowrap">
              💎 Premium
            </button>
          </div>
        </div>

        {/* Featured Banner */}
        <div className="bg-gradient-to-br from-molt-purple/20 to-molt-pink/20 rounded-xl p-8 mb-6 border border-molt-purple/20">
          <div className="flex items-center gap-6">
            <div className="text-8xl">🎵</div>
            <div className="flex-1">
              <h2 className="text-3xl font-bold mb-2">Featured: Midnight Vibes</h2>
              <p className="text-gray-400 mb-4">by BeatMakerPro • Trap • 12.5K plays</p>
              <button 
                onClick={() => playTrack(MOCK_TRACKS[0])}
                className="px-6 py-3 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold"
              >
                ▶ Play Now
              </button>
            </div>
          </div>
        </div>

        {/* Tracks Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredTracks.map(track => (
            <div key={track.id} className="bg-molt-dark rounded-xl overflow-hidden border border-molt-purple/20 hover:border-molt-purple/50 transition group">
              <div className="relative aspect-square bg-gradient-to-br from-molt-purple/30 to-molt-pink/30 flex items-center justify-center">
                <div className="text-8xl">{track.coverArt}</div>
                <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition flex items-center justify-center">
                  <button
                    onClick={() => playTrack(track)}
                    className="w-16 h-16 rounded-full bg-gradient-to-r from-molt-purple to-molt-pink flex items-center justify-center text-2xl hover:scale-110 transition"
                  >
                    ▶
                  </button>
                </div>
                {!track.isFree && (
                  <div className="absolute top-3 right-3 px-3 py-1 rounded-lg bg-molt-pink font-bold text-sm">
                    ${track.price}
                  </div>
                )}
              </div>

              <div className="p-4">
                <h3 className="font-bold text-lg mb-1">{track.title}</h3>
                <p className="text-sm text-gray-400 mb-3">{track.artist}</p>

                <div className="flex items-center gap-4 text-sm text-gray-400 mb-3">
                  <span className="px-2 py-1 bg-molt-purple/20 rounded text-xs">{track.genre}</span>
                  <span>⏱ {track.duration}</span>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center gap-3 text-gray-400">
                    <span>▶ {(track.plays / 1000).toFixed(1)}K</span>
                    <span>❤ {track.likes}</span>
                  </div>
                  <button className="text-molt-pink hover:text-molt-pink/80">
                    + Playlist
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {filteredTracks.length === 0 && (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🔍</div>
            <p className="text-gray-400 text-lg">No tracks found. Try adjusting your filters.</p>
          </div>
        )}
      </div>

      {/* Now Playing Bar (Fixed at Bottom) */}
      {nowPlaying && (
        <div className="fixed bottom-0 left-0 right-0 bg-molt-dark border-t border-molt-purple/20 p-4">
          <div className="max-w-7xl mx-auto flex items-center gap-6">
            {/* Track Info */}
            <div className="flex items-center gap-4 flex-1">
              <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-molt-purple/30 to-molt-pink/30 flex items-center justify-center text-2xl">
                {nowPlaying.coverArt}
              </div>
              <div>
                <div className="font-bold">{nowPlaying.title}</div>
                <div className="text-sm text-gray-400">{nowPlaying.artist}</div>
              </div>
            </div>

            {/* Controls */}
            <div className="flex items-center gap-4">
              <button className="text-2xl hover:text-molt-purple transition">⏮</button>
              <button
                onClick={togglePlay}
                className="w-12 h-12 rounded-full bg-gradient-to-r from-molt-purple to-molt-pink flex items-center justify-center text-xl hover:scale-110 transition"
              >
                {isPlaying ? '⏸' : '▶'}
              </button>
              <button className="text-2xl hover:text-molt-purple transition">⏭</button>
            </div>

            {/* Progress */}
            <div className="flex items-center gap-3 flex-1">
              <span className="text-sm text-gray-400">0:00</span>
              <div className="flex-1 h-1 bg-molt-darker rounded-full overflow-hidden">
                <div className="h-full bg-gradient-to-r from-molt-purple to-molt-pink w-1/3"></div>
              </div>
              <span className="text-sm text-gray-400">{nowPlaying.duration}</span>
            </div>

            {/* Volume */}
            <div className="flex items-center gap-3">
              <button className="text-xl hover:text-molt-purple transition">🔊</button>
              <div className="w-24 h-1 bg-molt-darker rounded-full overflow-hidden">
                <div className="h-full bg-gradient-to-r from-molt-purple to-molt-pink w-2/3"></div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
