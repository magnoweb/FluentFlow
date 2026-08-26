window.FluentFlow = window.FluentFlow || {};
window.FluentFlow._adminPlayer = null;
window.FluentFlow._dotNetRef   = null;

window.FluentFlow.playAudio = function (url, dotNetRef) {
    // Parar áudio anterior se existir
    if (window.FluentFlow._adminPlayer) {
        window.FluentFlow._adminPlayer.pause();
        window.FluentFlow._adminPlayer = null;
    }

    window.FluentFlow._dotNetRef   = dotNetRef;
    window.FluentFlow._adminPlayer = new Audio(url);

    window.FluentFlow._adminPlayer.play();

    // Quando o áudio termina — notificar o Blazor
    window.FluentFlow._adminPlayer.onended = function () {
        window.FluentFlow._adminPlayer = null;
        if (window.FluentFlow._dotNetRef) {
            window.FluentFlow._dotNetRef.invokeMethodAsync('OnAudioEnded');
        }
    };

    // Quando há erro — também notificar
    window.FluentFlow._adminPlayer.onerror = function () {
        window.FluentFlow._adminPlayer = null;
        if (window.FluentFlow._dotNetRef) {
            window.FluentFlow._dotNetRef.invokeMethodAsync('OnAudioEnded');
        }
    };
};

window.FluentFlow.stopAudio = function () {
    if (window.FluentFlow._adminPlayer) {
        window.FluentFlow._adminPlayer.pause();
        window.FluentFlow._adminPlayer = null;
    }
    window.FluentFlow._dotNetRef = null;
};