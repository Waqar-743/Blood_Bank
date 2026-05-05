/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./Landing Page.html",
    "./frontend/**/*.html",
    "./frontend/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        cream:   { 50:'#FDFBF7', 100:'#F8F4EC', 200:'#EFE8DA', 300:'#E2D8C2' },
        ink:     { 950:'#0E0B08', 900:'#1A1612', 850:'#1A1612', 800:'#2A2521', 700:'#3D3833', 600:'#5A544D' },
        sand:    { 400:'#8C857B', 500:'#6F6A62', 600:'#4F4B45' },
        crimson: { 400:'#E04149', 500:'#D02830', 600:'#A41E26', 700:'#6B1118', 800:'#3E0A0E' },
        teal:    { 300:'#5FC4BD', 400:'#3DB3AB', 500:'#2BA8A0', 600:'#1F8B85', 700:'#155F5B' },
        sage:    { 500:'#6B8E76' },
        // Admin-page back-compat aliases
        cr:      { 50:'#fef2f2', 400:'#C8323A', 500:'#A41E26', 600:'#8B1820', 700:'#6B1118' },
        sl:      { 200:'#E2D8C2', 300:'#C4BBA8', 400:'#8C857B', 500:'#6F6A62' },
      },
      fontFamily: {
        serif:   ['"Fraunces"','"Instrument Serif"','serif'],
        sans:    ['"Geist"','-apple-system','sans-serif'],
        mono:    ['"Geist Mono"','monospace'],
        display: ['"Fraunces"','serif'],
      },
    },
  },
  plugins: [],
};
