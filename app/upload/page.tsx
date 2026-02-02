'use client'

import { useState } from 'react'

type Collaborator = {
  name: string
  role: string
  split: number
}

export default function Upload() {
  const [step, setStep] = useState(1)
  const [trackFile, setTrackFile] = useState<File | null>(null)
  const [coverArt, setCoverArt] = useState<File | null>(null)
  const [title, setTitle] = useState('')
  const [genre, setGenre] = useState('')
  const [description, setDescription] = useState('')
  const [tags, setTags] = useState<string[]>([])
  const [tagInput, setTagInput] = useState('')
  const [price, setPrice] = useState(0)
  const [isFree, setIsFree] = useState(true)
  const [collaborators, setCollaborators] = useState<Collaborator[]>([])
  const [collabName, setCollabName] = useState('')
  const [collabRole, setCollabRole] = useState('')
  const [collabSplit, setCollabSplit] = useState(0)

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, type: 'track' | 'cover') => {
    const file = e.target.files?.[0]
    if (file) {
      if (type === 'track') {
        setTrackFile(file)
      } else {
        setCoverArt(file)
      }
    }
  }

  const addTag = () => {
    if (tagInput.trim() && !tags.includes(tagInput.trim())) {
      setTags([...tags, tagInput.trim()])
      setTagInput('')
    }
  }

  const removeTag = (tag: string) => {
    setTags(tags.filter(t => t !== tag))
  }

  const addCollaborator = () => {
    if (collabName && collabRole && collabSplit > 0) {
      setCollaborators([...collaborators, {
        name: collabName,
        role: collabRole,
        split: collabSplit
      }])
      setCollabName('')
      setCollabRole('')
      setCollabSplit(0)
    }
  }

  const removeCollaborator = (index: number) => {
    setCollaborators(collaborators.filter((_, i) => i !== index))
  }

  const totalSplit = collaborators.reduce((sum, c) => sum + c.split, 0)
  const remainingSplit = 100 - totalSplit

  const handleUpload = () => {
    // TODO: Implement actual upload to backend/IPFS
    alert('Track uploaded successfully! Your music is now live on MOLT MUSICAL MEDIA 🎵')
  }

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-4 bg-gradient-to-r from-molt-purple to-molt-pink bg-clip-text text-transparent">
            📤 Upload Your Track
          </h1>
          <p className="text-gray-400">Share your music with the world</p>
        </div>

        {/* Progress Steps */}
        <div className="flex items-center justify-between mb-8">
          {[1, 2, 3, 4].map(num => (
            <div key={num} className="flex items-center flex-1">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold ${
                step >= num ? 'bg-gradient-to-r from-molt-purple to-molt-pink' : 'bg-molt-darker border border-molt-purple/20'
              }`}>
                {num}
              </div>
              {num < 4 && (
                <div className={`flex-1 h-1 mx-2 ${
                  step > num ? 'bg-gradient-to-r from-molt-purple to-molt-pink' : 'bg-molt-darker'
                }`} />
              )}
            </div>
          ))}
        </div>

        {/* Step 1: Upload Files */}
        {step === 1 && (
          <div className="bg-molt-dark rounded-xl p-8 border border-molt-purple/20">
            <h2 className="text-2xl font-bold mb-6">Upload Files</h2>
            
            {/* Track Upload */}
            <div className="mb-6">
              <label className="block text-sm font-bold mb-2">Track File *</label>
              <div className="border-2 border-dashed border-molt-purple/30 rounded-lg p-8 text-center hover:border-molt-purple/50 transition cursor-pointer">
                <input
                  type="file"
                  accept="audio/*"
                  onChange={(e) => handleFileChange(e, 'track')}
                  className="hidden"
                  id="track-upload"
                />
                <label htmlFor="track-upload" className="cursor-pointer">
                  {trackFile ? (
                    <div>
                      <div className="text-4xl mb-2">✅</div>
                      <div className="font-bold text-molt-purple">{trackFile.name}</div>
                      <div className="text-sm text-gray-400">{(trackFile.size / 1024 / 1024).toFixed(2)} MB</div>
                    </div>
                  ) : (
                    <div>
                      <div className="text-4xl mb-2">🎵</div>
                      <div className="font-bold">Click to upload track</div>
                      <div className="text-sm text-gray-400">MP3, WAV, FLAC (max 50MB)</div>
                    </div>
                  )}
                </label>
              </div>
            </div>

            {/* Cover Art Upload */}
            <div className="mb-6">
              <label className="block text-sm font-bold mb-2">Cover Art</label>
              <div className="border-2 border-dashed border-molt-purple/30 rounded-lg p-8 text-center hover:border-molt-purple/50 transition cursor-pointer">
                <input
                  type="file"
                  accept="image/*"
                  onChange={(e) => handleFileChange(e, 'cover')}
                  className="hidden"
                  id="cover-upload"
                />
                <label htmlFor="cover-upload" className="cursor-pointer">
                  {coverArt ? (
                    <div>
                      <div className="text-4xl mb-2">🖼️</div>
                      <div className="font-bold text-molt-purple">{coverArt.name}</div>
                      <div className="text-sm text-gray-400">{(coverArt.size / 1024).toFixed(2)} KB</div>
                    </div>
                  ) : (
                    <div>
                      <div className="text-4xl mb-2">🎨</div>
                      <div className="font-bold">Click to upload cover art</div>
                      <div className="text-sm text-gray-400">JPG, PNG (recommended 3000x3000)</div>
                    </div>
                  )}
                </label>
              </div>
            </div>

            <button
              onClick={() => setStep(2)}
              disabled={!trackFile}
              className="w-full px-6 py-3 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next: Track Details →
            </button>
          </div>
        )}

        {/* Step 2: Track Details */}
        {step === 2 && (
          <div className="bg-molt-dark rounded-xl p-8 border border-molt-purple/20">
            <h2 className="text-2xl font-bold mb-6">Track Details</h2>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-bold mb-2">Title *</label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Enter track title"
                  className="w-full px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-bold mb-2">Genre *</label>
                <select
                  value={genre}
                  onChange={(e) => setGenre(e.target.value)}
                  className="w-full px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
                >
                  <option value="">Select genre</option>
                  <option value="Hip Hop">Hip Hop</option>
                  <option value="Trap">Trap</option>
                  <option value="R&B">R&B</option>
                  <option value="Pop">Pop</option>
                  <option value="Rock">Rock</option>
                  <option value="Country">Country</option>
                  <option value="EDM">EDM</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-bold mb-2">Description</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Tell us about your track..."
                  className="w-full h-32 px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none resize-none"
                />
              </div>

              <div>
                <label className="block text-sm font-bold mb-2">Tags</label>
                <div className="flex gap-2 mb-2">
                  <input
                    type="text"
                    value={tagInput}
                    onChange={(e) => setTagInput(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && addTag()}
                    placeholder="Add tags (e.g., chill, summer, vibes)"
                    className="flex-1 px-4 py-2 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
                  />
                  <button
                    onClick={addTag}
                    className="px-4 py-2 rounded-lg bg-molt-purple hover:bg-molt-purple/80 font-bold"
                  >
                    Add
                  </button>
                </div>
                <div className="flex flex-wrap gap-2">
                  {tags.map(tag => (
                    <span
                      key={tag}
                      className="px-3 py-1 bg-molt-purple/20 rounded-lg text-sm flex items-center gap-2"
                    >
                      {tag}
                      <button onClick={() => removeTag(tag)} className="text-red-400 hover:text-red-300">×</button>
                    </span>
                  ))}
                </div>
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setStep(1)}
                className="flex-1 px-6 py-3 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold"
              >
                ← Back
              </button>
              <button
                onClick={() => setStep(3)}
                disabled={!title || !genre}
                className="flex-1 px-6 py-3 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next: Pricing →
              </button>
            </div>
          </div>
        )}

        {/* Step 3: Pricing & Splits */}
        {step === 3 && (
          <div className="bg-molt-dark rounded-xl p-8 border border-molt-purple/20">
            <h2 className="text-2xl font-bold mb-6">Pricing & Revenue Splits</h2>
            
            <div className="space-y-6">
              {/* Pricing */}
              <div>
                <label className="flex items-center gap-3 mb-4">
                  <input
                    type="checkbox"
                    checked={isFree}
                    onChange={(e) => setIsFree(e.target.checked)}
                    className="w-5 h-5 rounded bg-molt-darker border-molt-purple/20"
                  />
                  <span className="font-bold">Free to stream</span>
                </label>
                
                {!isFree && (
                  <div>
                    <label className="block text-sm font-bold mb-2">Price (USDC)</label>
                    <input
                      type="number"
                      value={price}
                      onChange={(e) => setPrice(Number(e.target.value))}
                      placeholder="0.00"
                      min="0"
                      step="0.01"
                      className="w-full px-4 py-3 rounded-lg bg-molt-darker border border-molt-purple/20 focus:border-molt-purple outline-none"
                    />
                  </div>
                )}
              </div>

              {/* Collaborators */}
              <div>
                <h3 className="font-bold mb-3">Revenue Splits</h3>
                <p className="text-sm text-gray-400 mb-4">
                  Add collaborators and their revenue split percentages. Platform takes 2.5% fee.
                </p>

                <div className="bg-molt-darker rounded-lg p-4 mb-4">
                  <div className="grid grid-cols-3 gap-3 mb-3">
                    <input
                      type="text"
                      value={collabName}
                      onChange={(e) => setCollabName(e.target.value)}
                      placeholder="Name"
                      className="px-3 py-2 rounded-lg bg-molt-dark border border-molt-purple/20 focus:border-molt-purple outline-none text-sm"
                    />
                    <input
                      type="text"
                      value={collabRole}
                      onChange={(e) => setCollabRole(e.target.value)}
                      placeholder="Role"
                      className="px-3 py-2 rounded-lg bg-molt-dark border border-molt-purple/20 focus:border-molt-purple outline-none text-sm"
                    />
                    <div className="flex gap-2">
                      <input
                        type="number"
                        value={collabSplit || ''}
                        onChange={(e) => setCollabSplit(Number(e.target.value))}
                        placeholder="Split %"
                        min="0"
                        max={remainingSplit}
                        className="flex-1 px-3 py-2 rounded-lg bg-molt-dark border border-molt-purple/20 focus:border-molt-purple outline-none text-sm"
                      />
                      <button
                        onClick={addCollaborator}
                        disabled={!collabName || !collabRole || collabSplit <= 0 || collabSplit > remainingSplit}
                        className="px-3 py-2 rounded-lg bg-molt-purple hover:bg-molt-purple/80 font-bold text-sm disabled:opacity-50"
                      >
                        +
                      </button>
                    </div>
                  </div>

                  {collaborators.map((collab, i) => (
                    <div key={i} className="flex items-center justify-between py-2 border-t border-molt-purple/10">
                      <div>
                        <span className="font-bold">{collab.name}</span>
                        <span className="text-gray-400 text-sm ml-2">({collab.role})</span>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-molt-purple font-bold">{collab.split}%</span>
                        <button
                          onClick={() => removeCollaborator(i)}
                          className="text-red-400 hover:text-red-300 font-bold"
                        >
                          ×
                        </button>
                      </div>
                    </div>
                  ))}

                  <div className="flex items-center justify-between pt-3 mt-3 border-t border-molt-purple/20 font-bold">
                    <span>Remaining</span>
                    <span className="text-molt-pink">{remainingSplit}%</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setStep(2)}
                className="flex-1 px-6 py-3 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold"
              >
                ← Back
              </button>
              <button
                onClick={() => setStep(4)}
                className="flex-1 px-6 py-3 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold transition"
              >
                Next: Review →
              </button>
            </div>
          </div>
        )}

        {/* Step 4: Review & Publish */}
        {step === 4 && (
          <div className="bg-molt-dark rounded-xl p-8 border border-molt-purple/20">
            <h2 className="text-2xl font-bold mb-6">Review & Publish</h2>
            
            <div className="space-y-4 mb-6">
              <div className="flex justify-between">
                <span className="text-gray-400">Title:</span>
                <span className="font-bold">{title}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Genre:</span>
                <span className="font-bold">{genre}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Price:</span>
                <span className="font-bold">{isFree ? 'Free' : `$${price} USDC`}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Collaborators:</span>
                <span className="font-bold">{collaborators.length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Platform Fee:</span>
                <span className="font-bold text-molt-purple">2.5%</span>
              </div>
            </div>

            <div className="bg-molt-purple/10 rounded-lg p-4 mb-6 border border-molt-purple/20">
              <p className="text-sm">
                ✓ By uploading, you confirm you own all rights to this track or have permission to distribute it.
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => setStep(3)}
                className="flex-1 px-6 py-3 rounded-lg bg-molt-darker hover:bg-molt-darker/50 border border-molt-purple/20 font-bold"
              >
                ← Back
              </button>
              <button
                onClick={handleUpload}
                className="flex-1 px-6 py-3 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 font-bold transition pulse-glow"
              >
                🚀 Publish Track
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
