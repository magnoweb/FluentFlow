window.FluentFlow = window.FluentFlow || {};

// ── Player da sessão de estudo ────────────────────────────────────────────────
window.FluentFlow._studyPlayer    = null;
window.FluentFlow._studyDotNetRef = null;
window.FluentFlow._studyRate      = 1.0;

window.FluentFlow.studyPlay = function (url, dotNetRef, rate) {
    // Parar player anterior se existir
    if (window.FluentFlow._studyPlayer) {
        window.FluentFlow._studyPlayer.pause();
        window.FluentFlow._studyPlayer.onended = null;
        window.FluentFlow._studyPlayer.onerror = null;
        window.FluentFlow._studyPlayer = null;
    }

    window.FluentFlow._studyDotNetRef = dotNetRef;
    window.FluentFlow._studyRate      = rate || 1.0;

    var audio            = new Audio(url);
    audio.playbackRate   = window.FluentFlow._studyRate;
    window.FluentFlow._studyPlayer = audio;

    audio.play().catch(function (err) {
        console.warn('[FluentFlow] studyPlay error:', err);
        window.FluentFlow._studyPlayer = null;
        if (window.FluentFlow._studyDotNetRef) {
            window.FluentFlow._studyDotNetRef.invokeMethodAsync('OnStudyAudioEnded');
        }
    });

    audio.onended = function () {
        window.FluentFlow._studyPlayer = null;
        if (window.FluentFlow._studyDotNetRef) {
            window.FluentFlow._studyDotNetRef.invokeMethodAsync('OnStudyAudioEnded');
        }
    };

    audio.onerror = function () {
        window.FluentFlow._studyPlayer = null;
        if (window.FluentFlow._studyDotNetRef) {
            window.FluentFlow._studyDotNetRef.invokeMethodAsync('OnStudyAudioEnded');
        }
    };
};

window.FluentFlow.studyStop = function () {
    if (window.FluentFlow._studyPlayer) {
        window.FluentFlow._studyPlayer.pause();
        window.FluentFlow._studyPlayer.onended = null;
        window.FluentFlow._studyPlayer.onerror = null;
        window.FluentFlow._studyPlayer = null;
    }
};

// Verifica se o áudio está a tocar (útil para sincronizar ícone)
window.FluentFlow.studyIsPlaying = function () {
    var p = window.FluentFlow._studyPlayer;
    return p !== null && !p.paused && !p.ended;
};
