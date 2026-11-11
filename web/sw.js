'use strict';
// English Quest offline service worker.
// Network-first for the app's own files (so updates show up as soon as you are
// online), falling back to the cache when offline. Google font files are
// immutable, so they are served cache-first.

const CACHE = 'english-quest-v2';
const CORE = [
  './',
  'index.html',
  'manifest.json',
  'flutter.js',
  'flutter_bootstrap.js',
  'main.dart.js',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/assets/course.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/assets/fonts/NotoSansDevanagari-Regular.ttf',
  'assets/assets/fonts/NotoSansDevanagari-Bold.ttf',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) =>
      // Cache what we can; one missing file must not block installation.
      Promise.allSettled(CORE.map((url) => cache.add(new Request(url, { cache: 'reload' }))))
    )
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.filter((k) => k.startsWith('english-quest-') && k !== CACHE).map((k) => caches.delete(k)));
      await self.clients.claim();
    })()
  );
});

// The page sends the list of files it actually loaded (the CanvasKit build the
// browser picked, fallback fonts, etc.) so the first visit is fully offline-ready.
self.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.type !== 'cache-urls' || !Array.isArray(data.urls)) return;
  event.waitUntil(
    caches.open(CACHE).then((cache) =>
      Promise.allSettled(
        data.urls.filter(isCacheable).map(async (url) => {
          if (!(await cache.match(url))) await cache.add(url);
        })
      )
    )
  );
});

function isCacheable(url) {
  try {
    const u = new URL(url, self.registration.scope);
    if (u.origin === self.location.origin) return u.href.startsWith(self.registration.scope);
    return u.hostname === 'fonts.gstatic.com';
  } catch (_) {
    return false;
  }
}

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET' || !isCacheable(req.url)) return;
  const url = new URL(req.url);

  if (url.hostname === 'fonts.gstatic.com') {
    event.respondWith(
      caches.match(req).then(
        (hit) =>
          hit ||
          fetch(req).then((res) => {
            if (res.ok) {
              const copy = res.clone(); // clone now, before the page reads the body
              caches.open(CACHE).then((c) => c.put(req, copy));
            }
            return res;
          })
      )
    );
    return;
  }

  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE);
      try {
        const res = await fetch(req);
        if (res.ok && res.type === 'basic') cache.put(req, res.clone());
        return res;
      } catch (err) {
        const hit = (await cache.match(req, { ignoreSearch: true })) ||
          (req.mode === 'navigate' ? await cache.match('index.html') || await cache.match('./') : undefined);
        if (hit) return hit;
        throw err;
      }
    })()
  );
});
