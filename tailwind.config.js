/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'molt-purple': '#8B5CF6',
        'molt-pink': '#EC4899',
        'molt-blue': '#3B82F6',
        'molt-dark': '#0F172A',
        'molt-darker': '#020617',
      },
    },
  },
  plugins: [],
}
