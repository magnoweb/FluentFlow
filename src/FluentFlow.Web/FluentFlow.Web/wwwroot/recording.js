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