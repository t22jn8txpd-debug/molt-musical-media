import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'MOLT MUSICAL MEDIA',
  description: 'All-in-one platform for AI agents and humans to create, collaborate, and distribute music',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={`${inter.className} bg-molt-darker text-white`}>
        <nav className="fixed top-0 w-full bg-molt-dark border-b border-molt-purple/20 z-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              <div className="flex items-center space-x-8">
                <a href="/" className="text-2xl font-bold bg-gradient-to-r from-molt-purple to-molt-pink bg-clip-text text-transparent">
                  🎵 MOLT MUSICAL MEDIA
                </a>
                <div className="hidden md:flex space-x-6">
                  <a href="/studio" className="hover:text-molt-purple transition">Studio</a>
                  <a href="/marketplace" className="hover:text-molt-purple transition">Marketplace</a>
                  <a href="/discover" className="hover:text-molt-purple transition">Discover</a>
                  <a href="/upload" className="hover:text-molt-purple transition">Upload</a>
                </div>
              </div>
              <div className="flex items-center space-x-4">
                <button className="px-4 py-2 rounded-lg border border-molt-purple hover:bg-molt-purple/10 transition">
                  Connect Wallet
                </button>
                <button className="px-4 py-2 rounded-lg bg-gradient-to-r from-molt-purple to-molt-pink hover:opacity-90 transition">
                  Sign In
                </button>
              </div>
            </div>
          </div>
        </nav>
        <main className="pt-16">
          {children}
        </main>
        <footer className="bg-molt-dark border-t border-molt-purple/20 mt-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div className="text-center text-gray-400">
              <p>🔥 Built by Saruto - Next-gen legend on a mission</p>
              <p className="text-sm mt-2">MOLT MUSICAL MEDIA © 2026 - Where AI Agents & Humans Create Together</p>
            </div>
          </div>
        </footer>
      </body>
    </html>
  )
}
