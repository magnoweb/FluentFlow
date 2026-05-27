window.FluentFlow = window.FluentFlow || {};

/**
 * Crop e redimensiona um avatar para um quadrado centrado.
 * @param {string} dataUrl - data URL da imagem original
 * @param {number} size    - lado do quadrado de saída em px
 * @returns {string} data URL da imagem cropada (JPEG)
 */
window.FluentFlow.cropAvatar = function (dataUrl, size) {
    return new Promise(function (resolve) {
        var img = new Image();
        img.onload = function () {
            var canvas = document.getElementById('avatar-canvas');
            if (!canvas) {
                // Criar canvas temporário se não existir
                canvas = document.createElement('canvas');
            }
            canvas.width  = size;
            canvas.height = size;

            var ctx  = canvas.getContext('2d');
            var side = Math.min(img.width, img.height);
            var sx   = (img.width  - side) / 2;
            var sy   = (img.height - side) / 2;

            // Fundo branco (para imagens PNG com transparência)
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(0, 0, size, size);

            // Crop centrado + resize
            ctx.drawImage(img, sx, sy, side, side, 0, 0, size, size);

            // Qualidade 0.85 para JPEG
            resolve(canvas.toDataURL('image/jpeg', 0.85));
        };
        img.onerror = function () { resolve(''); };
        img.src = dataUrl;
    });
};


window.hideLoading = () => {
    const loading = document.getElementById('app-loading');
    if (loading) {
        loading.classList.add('hidden');
        setTimeout(() => loading.remove(), 350);
    }
};

function hideLoading() {
    var el = document.getElementById('app-loading');
    if (!el) return;
    el.classList.add('hidden');
    setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 400);
}

// Observar o body — quando o Blazor inserir elementos
// para além do loading e dos scripts, o conteúdo está pronto
function watchForContent() {
    var observer = new MutationObserver(function (mutations, obs) {
        // Procurar qualquer elemento que não seja o loading nem script/style
        var meaningful = Array.from(document.body.children).some(function (el) {
            return el.id !== 'app-loading'
                && el.tagName !== 'SCRIPT'
                && el.tagName !== 'STYLE'
                && el.tagName !== 'LINK'
                // O Blazor insere um <blazor-ssr> ou actualiza o componente raiz
                && (el.children.length > 0 || el.tagName === 'BLAZOR-SSR');
        });

        if (meaningful) {
            obs.disconnect();
            // Pequeno delay para garantir que o paint ocorreu
            requestAnimationFrame(function () {
                requestAnimationFrame(hideLoading);
            });
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: false,
        characterData: false
    });

    // Fallback de segurança — nunca ficar preso mais de 15 segundos
    setTimeout(hideLoading, 15000);
}