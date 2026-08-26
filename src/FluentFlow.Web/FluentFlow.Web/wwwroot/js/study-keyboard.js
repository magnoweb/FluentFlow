window.FluentFlow = window.FluentFlow || {};

window.FluentFlow._keyboardRef     = null;
window.FluentFlow._keyboardHandler = null;

window.FluentFlow.registerKeyboard = function (dotNetRef) {
    window.FluentFlow._keyboardRef = dotNetRef;

    window.FluentFlow._keyboardHandler = async function (e) {
        // Ignorar quando o foco está num campo de texto
        const tag = document.activeElement?.tagName?.toLowerCase();
        if (tag === 'input' || tag === 'textarea' || tag === 'select') return;

        // Ignorar combinações com modificadores (Ctrl+R, Alt+F4, etc.)
        if (e.ctrlKey || e.altKey || e.metaKey) return;

        const key = e.key;
        const ref = window.FluentFlow._keyboardRef;
        if (!ref) return;

        switch (key) {

            // ── ↑ / ↓ — virar card ─────────────────────────────────────
            case 'ArrowUp':
            case 'ArrowDown':
                e.preventDefault();
                await ref.invokeMethodAsync('OnFlipPressed');
                break;

            // ── ← / → — repetir áudio (Listening) ─────────────────────
            case 'ArrowLeft':
            case 'ArrowRight':
                e.preventDefault();
                await ref.invokeMethodAsync('OnReplayPressed');
                break;

            // ── Espaço — gravar/parar (Speaking) | virar (Listening) ───
            case ' ':
            case 'Spacebar':
                e.preventDefault();
                await ref.invokeMethodAsync('OnSpacePressed');
                break;

            // ── Enter — confirmar score pendente ───────────────────────
            case 'Enter':
                e.preventDefault();
                await ref.invokeMethodAsync('OnEnterPressed');
                break;

            // ── 0–5 — submeter score ────────────────────────────────────
            default:
                if (/^[0-5]$/.test(key)) {
                    e.preventDefault();
                    await ref.invokeMethodAsync('OnNumberPressed', parseInt(key, 10));
                }
                break;
        }
    };

    document.addEventListener('keydown', window.FluentFlow._keyboardHandler);
};

window.FluentFlow.unregisterKeyboard = function () {
    if (window.FluentFlow._keyboardHandler) {
        document.removeEventListener('keydown', window.FluentFlow._keyboardHandler);
        window.FluentFlow._keyboardHandler = null;
        window.FluentFlow._keyboardRef     = null;
    }
};