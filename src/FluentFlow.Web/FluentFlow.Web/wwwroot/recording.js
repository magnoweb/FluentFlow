window.FluentFlow = window.FluentFlow || {};

window.FluentFlow.startRecording = async function () {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({
            audio: {
                sampleRate:   16000,
                channelCount: 1,
                echoCancellation: true,
                noiseSuppression: true,
            }
        });

        window.FluentFlow._audioChunks   = [];
        window.FluentFlow._recordingStream = stream;

        // Preferir WAV PCM se disponível, senão MP3, senão webm
        const mimeType = [
            'audio/wav',
            'audio/wave',
            'audio/x-wav',
            'audio/mp3',
            'audio/mpeg',
            'audio/webm;codecs=pcm',
            'audio/webm;codecs=opus',
            'audio/webm',
            'audio/ogg;codecs=opus',
        ].find(t => MediaRecorder.isTypeSupported(t)) ?? '';

        console.log('[FluentFlow] Recording MIME type:', mimeType || 'browser default');

        window.FluentFlow._mediaRecorder = new MediaRecorder(stream, mimeType ? { mimeType } : undefined);

        window.FluentFlow._mediaRecorder.ondataavailable = function (e) {
            if (e.data && e.data.size > 0)
                window.FluentFlow._audioChunks.push(e.data);
        };

        window.FluentFlow._mediaRecorder.start(100);
    } catch (err) {
        console.error('[FluentFlow] Error accessing the microphone:', err);
        throw err;
    }
};

window.FluentFlow.stopRecording = function () {
    return new Promise(function (resolve) {
        const recorder = window.FluentFlow._mediaRecorder;

        if (!recorder || recorder.state === 'inactive') {
            resolve(JSON.stringify({ base64: '', extension: '.wav' }));
            return;
        }

        recorder.onstop = async function () {
            // Parar todas as tracks
            window.FluentFlow._recordingStream?.getTracks().forEach(t => t.stop());

            const mimeType = recorder.mimeType || 'audio/webm';
            const blob     = new Blob(window.FluentFlow._audioChunks,{ type: mimeType });

            // Determinar extensão com base no MIME type gravado
            const extension = mimeType.includes('wav') ? '.wav'
                : mimeType.includes('mp3') ? '.mp3'
                    : mimeType.includes('mpeg') ? '.mp3'
                        : mimeType.includes('ogg') ? '.ogg'
                            : '.webm'; // fallback

            const reader = new FileReader();
            reader.onloadend = function () {
                const base64 = reader.result.split(',')[1];
                // Retornar base64 + extensão para o Blazor
                resolve(JSON.stringify({ base64, extension }));
            };
            reader.readAsDataURL(blob);
        };

        recorder.stop();
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