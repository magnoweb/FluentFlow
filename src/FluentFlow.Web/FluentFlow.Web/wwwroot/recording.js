window.FluentFlow = window.FluentFlow || {};

window.FluentFlow.startRecording = async function () {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

        window.FluentFlow._audioChunks   = [];
        window.FluentFlow._mediaRecorder = new MediaRecorder(stream, {
            mimeType: MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
                ? 'audio/webm;codecs=opus'
                : 'audio/ogg;codecs=opus'
        });

        window.FluentFlow._mediaRecorder.ondataavailable = function (e) {
            if (e.data.size > 0)
                window.FluentFlow._audioChunks.push(e.data);
        };

        window.FluentFlow._mediaRecorder.start(100);
    } catch (err) {
        console.error('Erro ao aceder ao microfone:', err);
        throw err;
    }
};

window.FluentFlow.stopRecording = function () {
    return new Promise(function (resolve) {
        if (!window.FluentFlow._mediaRecorder ||
            window.FluentFlow._mediaRecorder.state === 'inactive') {
            resolve('');
            return;
        }

        window.FluentFlow._mediaRecorder.onstop = async function () {
            const blob = new Blob(window.FluentFlow._audioChunks, {
                type: window.FluentFlow._mediaRecorder.mimeType
            });

            window.FluentFlow._mediaRecorder.stream
                .getTracks()
                .forEach(function (t) { t.stop(); });

            const reader = new FileReader();
            reader.onloadend = function () {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.readAsDataURL(blob);
        };

        window.FluentFlow._mediaRecorder.stop();
    });
};

/*
window.FluentFlow = {

    _mediaRecorder: null,
    _audioChunks: [],

    startRecording: async function () {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

            FluentFlow._audioChunks = [];
            FluentFlow._mediaRecorder = new MediaRecorder(stream, {
                mimeType: MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
                    ? 'audio/webm;codecs=opus'
                    : 'audio/ogg;codecs=opus'
            });

            FluentFlow._mediaRecorder.ondataavailable = (e) => {
                if (e.data.size > 0)
                    FluentFlow._audioChunks.push(e.data);
            };

            FluentFlow._mediaRecorder.start(100); // chunk a cada 100ms
        } catch (err) {
            console.error('Erro ao aceder ao microfone:', err);
            throw err;
        }
    },

    stopRecording: function () {
        return new Promise((resolve) => {
            if (!FluentFlow._mediaRecorder ||
                FluentFlow._mediaRecorder.state === 'inactive') {
                resolve('');
                return;
            }

            FluentFlow._mediaRecorder.onstop = async () => {
                const blob = new Blob(FluentFlow._audioChunks, {
                    type: FluentFlow._mediaRecorder.mimeType
                });

                // Parar todas as tracks do microfone
                FluentFlow._mediaRecorder.stream
                    .getTracks()
                    .forEach(t => t.stop());

                // Converter para base64
                const reader = new FileReader();
                reader.onloadend = () => {
                    // Remover prefixo "data:audio/...;base64,"
                    const base64 = reader.result.split(',')[1];
                    resolve(base64);
                };
                reader.readAsDataURL(blob);
            };

            FluentFlow._mediaRecorder.stop();
        });
    }
};
*/