// Service worker de produção — cache de assets
const CACHE_NAME = 'fluentflow-cache-v1';
const OFFLINE_URL = '/offline.html';

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache =>
            cache.addAll(self.assetsManifest?.assets
                .filter(a => a.url)
                .map(a => a.url) ?? [])
        )
    );
    self.skipWaiting();
});

self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys =>
            Promise.all(keys
                .filter(k => k !== CACHE_NAME)
                .map(k => caches.delete(k)))
        )
    );
    self.clients.claim();
});

self.addEventListener('fetch', event => {
    if (event.request.method !== 'GET') return;

    event.respondWith(
        caches.match(event.request).then(cached => {
            if (cached) return cached;
            return fetch(event.request).catch(() =>
                caches.match(OFFLINE_URL));
        })
    );
});