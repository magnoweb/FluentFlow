import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

class MiniWaveformIcon extends StatefulWidget {
  const MiniWaveformIcon({super.key});

  @override
  State<MiniWaveformIcon> createState() => _MiniWaveformIconState();
}

class _MiniWaveformIconState extends State<MiniWaveformIcon> {
  // A Stream precisa enviar objetos do tipo 'Amplitude' exigidos pela lib
  final StreamController<Amplitude> _streamController = StreamController<Amplitude>.broadcast();
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Dispara a cada 100ms para manter o movimento fluido
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_streamController.isClosed) {
        // Geramos uma amplitude aleatória mapeada para o modelo da biblioteca
        final fakeAmplitude = Amplitude(
          current: _random.nextDouble() * 100, // Valor atual da onda
          max: 100,                           // Valor máximo possível
        );
        _streamController.add(fakeAmplitude);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedWaveList(
      stream: _streamController.stream,
    );
  }
}