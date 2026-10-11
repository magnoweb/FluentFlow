window.FluentFlow = window.FluentFlow || {};

// ── Player de podcasts ────────────────────────────────────────────────────────
// Um único <audio> controlado a partir do Blazor (PodcastPlayer.razor).
// Todos os tempos trocados com o .NET estão em SEGUNDOS do ficheiro actual;
// a conversão para a escala "normal" (versão lenta) é feita no C#.
(function () {
    const state = {
        audio: null,
        ref: null,
        timer: null,
        loop: null,          // { start, end } em segundos
        lastReported: -1,
        keyHandler: null,
    };

    function invoke(method, ...args) {
        if (!state.ref) return;
        state.ref.invokeMethodAsync(method, ...args).catch(() => { /* componente já descartado */ });
    }

    function tick() {
        const a = state.audio;
        if (!a) return;

        // Repetição de frase (A-B loop)
        if (state.loop && a.currentTime >= state.loop.end) {
            a.currentTime = state.loop.start;
        }

        if (Math.abs(a.currentTime - state.lastReported) >= 0.2) {
            state.lastReported = a.currentTime;
            invoke('OnPodcastTime', a.currentTime);
        }
    }

    function startTimer() {
        stopTimer();
        state.timer = setInterval(tick, 150);
    }

    function stopTimer() {
        if (state.timer) {
            clearInterval(state.timer);
            state.timer = null;
        }
    }

    function setupMediaSession(meta) {
        if (!('mediaSession' in navigator) || !meta) return;
        try {
            navigator.mediaSession.metadata = new MediaMetadata({
                title: meta.title || 'FluentFlow',
                artist: meta.artist || 'FluentFlow',
                album: meta.album || 'FluentFlow Podcast',
                artwork: [{ src: '/icon-512.png', sizes: '512x512', type: 'image/png' }],
            });
            const handlers = {
                play: () => FluentFlow.podcastPlay(),
                pause: () => FluentFlow.podcastPause(),
                seekbackward: () => FluentFlow.podcastSkip(-10),
                seekforward: () => FluentFlow.podcastSkip(10),
                previoustrack: () => invoke('OnPodcastCommand', 'previousEpisode'),
                nexttrack: () => invoke('OnPodcastCommand', 'nextEpisode'),
                seekto: (d) => { if (d && typeof d.seekTime === 'number') FluentFlow.podcastSeek(d.seekTime); },
            };
            for (const [action, handler] of Object.entries(handlers)) {
                try { navigator.mediaSession.setActionHandler(action, handler); } catch { /* não suportado */ }
            }
        } catch (e) {
            console.warn('[FluentFlow] mediaSession:', e);
        }
    }

    function attach(audio) {
        // Os handlers ignoram eventos de um <audio> que já foi substituído/descartado
        const current = () => state.audio === audio;
        audio.addEventListener('play', () => { if (!current()) return; startTimer(); invoke('OnPodcastState', true); });
        audio.addEventListener('pause', () => {
            if (!current()) return;
            stopTimer();
            state.lastReported = -1;
            tick();
            invoke('OnPodcastState', false);
        });
        audio.addEventListener('ended', () => {
            if (!current()) return;
            stopTimer();
            invoke('OnPodcastEnded');
        });
        audio.addEventListener('error', () => {
            if (!current()) return;
            stopTimer();
            const code = audio.error ? audio.error.code : 0;
            invoke('OnPodcastError', 'media-error-' + code);
        });
    }

    function destroyAudio() {
        stopTimer();
        if (state.audio) {
            const a = state.audio;
            state.audio = null;
            a.pause();
            a.removeAttribute('src');
            try { a.load(); } catch { /* ignorar */ }
        }
        state.loop = null;
        state.lastReported = -1;
    }

    /**
     * Carrega um episódio.
     * @param {string} url       URL do mp3
     * @param {number} startSec  posição inicial (s)
     * @param {number} rate      velocidade (playbackRate)
     * @param {object} dotNetRef referência .NET (PodcastPlayer)
     * @param {object} meta      { title, artist, album } para a Media Session
     * @param {boolean} autoplay começar a tocar logo que possível
     */
    FluentFlow.podcastLoad = function (url, startSec, rate, dotNetRef, meta, autoplay) {
        destroyAudio();
        state.ref = dotNetRef;

        const audio = new Audio();
        audio.preload = 'auto';
        audio.playbackRate = rate || 1;
        state.audio = audio;
        attach(audio);

        audio.addEventListener('loadedmetadata', () => {
            if (startSec > 0 && isFinite(audio.duration)) {
                audio.currentTime = Math.min(startSec, Math.max(audio.duration - 0.5, 0));
            }
            audio.playbackRate = rate || 1;
            state.lastReported = -1;
            tick();
            invoke('OnPodcastLoaded', isFinite(audio.duration) ? audio.duration : 0);
            if (autoplay) FluentFlow.podcastPlay();
        }, { once: true });

        audio.src = url;
        setupMediaSession(meta);
    };

    /** Troca o ficheiro (ex.: versão lenta) mantendo a posição e o estado de reprodução. */
    FluentFlow.podcastSwitchSource = function (url, startSec, rate, play) {
        const old = state.audio;
        if (old) {
            old.pause();
            stopTimer();
        }
        const audio = new Audio();
        audio.preload = 'auto';
        state.audio = audio;
        attach(audio);
        audio.addEventListener('loadedmetadata', () => {
            if (isFinite(audio.duration)) {
                audio.currentTime = Math.min(Math.max(startSec, 0), Math.max(audio.duration - 0.5, 0));
            }
            audio.playbackRate = rate || 1;
            state.lastReported = -1;
            tick();
            invoke('OnPodcastLoaded', isFinite(audio.duration) ? audio.duration : 0);
            if (play) FluentFlow.podcastPlay();
        }, { once: true });
        audio.src = url;
        if (old) {
            old.removeAttribute('src');
            try { old.load(); } catch { /* ignorar */ }
        }
    };

    /** @returns {Promise<boolean>} false se o browser bloquear o autoplay */
    FluentFlow.podcastPlay = async function () {
        if (!state.audio) return false;
        try {
            await state.audio.play();
            return true;
        } catch (e) {
            console.warn('[FluentFlow] podcastPlay:', e);
            invoke('OnPodcastState', false);
            return false;
        }
    };

    FluentFlow.podcastPause = function () {
        if (state.audio) state.audio.pause();
    };

    FluentFlow.podcastToggle = function () {
        if (!state.audio) return;
        if (state.audio.paused) FluentFlow.podcastPlay(); else state.audio.pause();
    };

    FluentFlow.podcastSeek = function (sec) {
        const a = state.audio;
        if (!a) return;
        const max = isFinite(a.duration) ? Math.max(a.duration - 0.05, 0) : sec;
        a.currentTime = Math.min(Math.max(sec, 0), max);
        state.lastReported = -1;
        tick();
    };

    FluentFlow.podcastSkip = function (deltaSec) {
        if (state.audio) FluentFlow.podcastSeek(state.audio.currentTime + deltaSec);
    };

    FluentFlow.podcastSetRate = function (rate) {
        if (state.audio) state.audio.playbackRate = rate || 1;
    };

    /** Repetir um intervalo (frase). Passar null para desligar. */
    FluentFlow.podcastSetLoop = function (startSec, endSec) {
        state.loop = (startSec === null || endSec === null || endSec <= startSec)
            ? null
            : { start: startSec, end: endSec };
    };

    FluentFlow.podcastGetTime = function () {
        return state.audio ? state.audio.currentTime : 0;
    };

    FluentFlow.podcastDestroy = function () {
        destroyAudio();
        state.ref = null;
        if ('mediaSession' in navigator) {
            try { navigator.mediaSession.metadata = null; } catch { /* ignorar */ }
        }
    };

    /**
     * Leva a linha activa para o topo do contentor da transcrição, deixando o elemento
     * anterior (frase anterior ou cabeçalho da secção) visível acima dela — a linha actual
     * fica em 1.º/2.º lugar. Não mexe no scroll da página.
     * Usa getBoundingClientRect (offsetTop dependia do offsetParent e falhava às vezes)
     * e espera pelo próximo frame para o Blazor já ter aplicado a classe activa.
     */
    FluentFlow.podcastScrollToLine = function (containerId, lineId) {
        requestAnimationFrame(function () {
            const container = document.getElementById(containerId);
            const line = document.getElementById(lineId);
            if (!container || !line) return;

            const anchor = line.previousElementSibling || line;
            const containerTop = container.getBoundingClientRect().top + container.clientTop;
            const anchorTop = anchor.getBoundingClientRect().top;
            const padding = 8;

            const max = container.scrollHeight - container.clientHeight;
            const target = Math.min(Math.max(container.scrollTop + (anchorTop - containerTop) - padding, 0), max);
            if (Math.abs(target - container.scrollTop) < 2) return;
            container.scrollTo({ top: target, behavior: 'smooth' });
        });
    };

    // ── Atalhos de teclado ─────────────────────────────────────────────────────
    FluentFlow.podcastRegisterKeys = function (dotNetRef) {
        FluentFlow.podcastUnregisterKeys();
        state.keyHandler = function (e) {
            const tag = document.activeElement?.tagName?.toLowerCase();
            if (tag === 'input' || tag === 'textarea' || tag === 'select') return;
            if (e.ctrlKey || e.altKey || e.metaKey) return;

            switch (e.key) {
                case ' ':
                case 'Spacebar':
                case 'k':
                    e.preventDefault();
                    FluentFlow.podcastToggle();
                    break;
                case 'ArrowLeft':
                    e.preventDefault();
                    FluentFlow.podcastSkip(-5);
                    break;
                case 'ArrowRight':
                    e.preventDefault();
                    FluentFlow.podcastSkip(5);
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    dotNetRef.invokeMethodAsync('OnPodcastCommand', 'previousLine').catch(() => { });
                    break;
                case 'ArrowDown':
                    e.preventDefault();
                    dotNetRef.invokeMethodAsync('OnPodcastCommand', 'nextLine').catch(() => { });
                    break;
                case 'l':
                case 'L':
                    dotNetRef.invokeMethodAsync('OnPodcastCommand', 'loop').catch(() => { });
                    break;
                case 't':
                case 'T':
                    dotNetRef.invokeMethodAsync('OnPodcastCommand', 'translation').catch(() => { });
                    break;
            }
        };
        document.addEventListener('keydown', state.keyHandler);
    };

    FluentFlow.podcastUnregisterKeys = function () {
        if (state.keyHandler) {
            document.removeEventListener('keydown', state.keyHandler);
            state.keyHandler = null;
        }
    };
})();
