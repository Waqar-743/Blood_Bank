'use strict';

// Intersection reveal
const io = new IntersectionObserver((entries) => {
  entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
}, { threshold: 0.12 });
document.querySelectorAll('.reveal, .reveal-l, .reveal-r, .stagger, .ecg, .word').forEach(el => io.observe(el));

// Mobile menu
const burgerBtn = document.getElementById('burger-btn');
const burger    = document.getElementById('burger');
const menu      = document.getElementById('menu');
let menuOpen    = false;

function toggleMenu(force) {
  menuOpen = force !== undefined ? force : !menuOpen;
  burger.classList.toggle('open', menuOpen);
  if (menuOpen) {
    menu.classList.add('open');
    menu.style.opacity = '1';
    menu.style.pointerEvents = 'auto';
    document.body.style.overflow = 'hidden';
  } else {
    menu.classList.remove('open');
    menu.style.opacity = '0';
    menu.style.pointerEvents = 'none';
    document.body.style.overflow = '';
  }
}
burgerBtn.addEventListener('click', () => toggleMenu());
document.querySelectorAll('#menu a').forEach(a => a.addEventListener('click', () => toggleMenu(false)));

// Hero phrase rotator
const phrases   = ['a lifeline', 'a heartbeat', 'a second chance', 'a promise kept'];
let pi          = 0;
const heroPhrase = document.getElementById('heroPhrase');
setInterval(() => {
  pi = (pi + 1) % phrases.length;
  heroPhrase.style.transition = 'opacity .5s var(--ease), transform .6s var(--ease), filter .5s var(--ease)';
  heroPhrase.style.opacity   = '0';
  heroPhrase.style.transform = 'translateY(12px)';
  heroPhrase.style.filter    = 'blur(6px)';
  setTimeout(() => {
    heroPhrase.textContent     = phrases[pi];
    heroPhrase.style.opacity   = '1';
    heroPhrase.style.transform = 'translateY(0)';
    heroPhrase.style.filter    = 'blur(0)';
  }, 420);
}, 3400);

// Blood stock drops
const groups = [
  { type: 'O−',  pct: 18,  units: 142,   status: 'critical' },
  { type: 'AB−', pct: 22,  units: 96,    status: 'critical' },
  { type: 'A−',  pct: 41,  units: 312,   status: 'low' },
  { type: 'B−',  pct: 47,  units: 388,   status: 'low' },
  { type: 'O+',  pct: 78,  units: 2840,  status: 'stable' },
  { type: 'A+',  pct: 71,  units: 2104,  status: 'stable' },
  { type: 'B+',  pct: 64,  units: 1612,  status: 'stable' },
  { type: 'AB+', pct: 58,  units: 921,   status: 'stable' },
];

const statusColor = { critical: '#A41E26', low: '#D97706', stable: '#6B8E76' };
const statusLabel = { critical: 'CRITICAL', low: 'LOW', stable: 'STABLE' };

const grid = document.getElementById('dropsGrid');
groups.forEach((g, i) => {
  const fillH = Math.max(8, Math.round(g.pct * 1.3));
  const color = statusColor[g.status];
  const node  = document.createElement('div');
  node.innerHTML = `
    <div class="relative">
      <svg viewBox="0 0 100 140" class="w-full">
        <defs>
          <clipPath id="clip-${i}">
            <path d="M50 4 C50 4, 12 56, 12 92 a38 38 0 0 0 76 0 C88 56, 50 4, 50 4 Z"/>
          </clipPath>
          <linearGradient id="grad-${i}" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stop-color="${color}" stop-opacity="0.95"/>
            <stop offset="100%" stop-color="${color}" stop-opacity="0.55"/>
          </linearGradient>
        </defs>
        <path d="M50 4 C50 4, 12 56, 12 92 a38 38 0 0 0 76 0 C88 56, 50 4, 50 4 Z"
              fill="rgba(14,11,8,0.04)" stroke="rgba(14,11,8,0.18)" stroke-width="1.2"/>
        <g clip-path="url(#clip-${i})">
          <rect x="-20" y="${140 - fillH}" width="160" height="${fillH + 40}" fill="url(#grad-${i})"/>
          <path class="wave" d="M-20 ${140 - fillH} q 10 -6 20 0 t 20 0 t 20 0 t 20 0 t 20 0 t 20 0 v 40 H -20 Z"
                fill="${color}" opacity="0.55"/>
          <path class="wave" style="animation-duration:9s" d="M-20 ${140 - fillH + 4} q 12 -8 24 0 t 24 0 t 24 0 t 24 0 t 24 0 v 40 H -20 Z"
                fill="${color}" opacity="0.35"/>
        </g>
        <ellipse cx="38" cy="70" rx="4" ry="10" fill="white" opacity="0.35"/>
      </svg>
      <div class="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
        <div class="serif font-light text-cream-50 text-[40px] leading-none drop-shadow tracking-[-0.04em]">${g.type}</div>
        <div class="mono text-[10px] text-cream-50/85 mt-1 tracking-wider">${g.pct}%</div>
      </div>
    </div>
    <div class="mt-4 flex items-center justify-between">
      <div class="mono text-[10px] tracking-widest" style="color:${color}">● ${statusLabel[g.status]}</div>
      <div class="mono text-[10px] text-sand-500">${g.units.toLocaleString()} U</div>
    </div>
    <div class="mt-2 h-[2px] bg-ink-950/8 overflow-hidden rounded-full">
      <div style="width:${g.pct}%; background:${color}" class="h-full transition-all duration-1000"></div>
    </div>
  `;
  grid.appendChild(node);
});

// Animated counters
const easeOut     = t => 1 - Math.pow(1 - t, 3);
const formatNumber = (n, suffix) => {
  if (suffix === 'L') {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(2).replace(/\.?0+$/, '') + 'M L';
    if (n >= 1000)      return (n / 1000).toFixed(0) + 'K L';
    return n.toLocaleString() + ' L';
  }
  if (suffix === '+') {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(2).replace(/\.?0+$/, '') + 'M+';
    if (n >= 1000)      return Math.round(n / 1000) + 'K+';
    return n.toLocaleString() + '+';
  }
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(2).replace(/\.?0+$/, '') + 'M';
  if (n >= 100_000)   return Math.round(n / 1000) + 'K';
  return n.toLocaleString();
};

const counterIO = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (!e.isIntersecting) return;
    const el     = e.target;
    const target = parseInt(el.dataset.counter, 10);
    const suffix = el.dataset.suffix || '';
    const dur    = 1800;
    const start  = performance.now();
    const tick   = (now) => {
      const t   = Math.min(1, (now - start) / dur);
      const val = Math.floor(easeOut(t) * target);
      el.textContent = formatNumber(val, suffix);
      if (t < 1) requestAnimationFrame(tick);
      else el.textContent = formatNumber(target, suffix);
    };
    requestAnimationFrame(tick);
    counterIO.unobserve(el);
  });
}, { threshold: 0.4 });
document.querySelectorAll('[data-counter]').forEach(el => counterIO.observe(el));

// Nav scroll compress
const navEl = document.getElementById('nav');
let lastScroll = 0;
window.addEventListener('scroll', () => {
  const y = window.scrollY;
  if (y > 30 && lastScroll <= 30)      navEl.style.background = 'rgba(253,251,247,0.85)';
  else if (y <= 30 && lastScroll > 30) navEl.style.background = '';
  lastScroll = y;
}, { passive: true });

// Page loader
(function () {
  const loader  = document.getElementById('page-loader');
  const bar     = document.getElementById('ldr-bar');
  const status  = document.getElementById('ldr-status');
  const fill    = document.getElementById('ldr-fill');
  if (!loader) return;

  const MIN_MS  = 450;
  const MAX_MS  = 3500;
  const start   = Date.now();
  let dismissed = false;

  function setProgress(p) {
    p = Math.min(100, p);
    bar.style.width = p + '%';
    fill.setAttribute('y', String(Math.round(80 - (p / 100) * 74)));
    if (p >= 100) status.textContent = 'READY';
  }

  function dismiss() {
    if (dismissed) return;
    dismissed = true;
    setProgress(100);
    const elapsed = Date.now() - start;
    const wait    = Math.max(0, MIN_MS - elapsed);
    setTimeout(() => loader.classList.add('done'), wait + 300);
  }

  const imgs = Array.from(document.querySelectorAll('img')).filter(
    img => img.loading !== 'lazy' && !img.hasAttribute('data-skip-loader')
  );
  if (!imgs.length) { dismiss(); return; }

  let settled   = 0;
  const total   = imgs.length;

  function onSettled() {
    settled = Math.min(total, settled + 1);
    setProgress(Math.round((settled / total) * 100));
    if (settled >= total) dismiss();
  }

  imgs.forEach(img => {
    if (img.complete) { onSettled(); }
    else {
      img.addEventListener('load',  onSettled, { once: true });
      img.addEventListener('error', onSettled, { once: true });
    }
  });

  setTimeout(dismiss, MAX_MS);
  requestAnimationFrame(() => setProgress(4));
})();
