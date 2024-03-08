import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';

class RivePage extends StatefulWidget {
  final bool isBark;
  final bool isHeadUp;
  final bool isHeadDown;
  final bool isTilt;
  const RivePage({
    Key? key,
    required this.isBark,
    required this.isHeadUp,
    required this.isHeadDown,
    required this.isTilt,
  }) : super(key: key);

  @override
  State<RivePage> createState() => _RivePageState();
}

class _RivePageState extends State<RivePage> {
  late StateMachineController _controller;
  late AudioPlayer player;
  late Stream<ProcessingState> audioStream;
  SMIInput<bool>? _bark;
  SMIInput<bool>? _headUp;
  SMIInput<bool>? _tilt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      player = AudioPlayer();
      final content = await rootBundle.load('assets/sound/barktwice.mp3');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/barktwice');
      file.writeAsBytesSync(content.buffer.asUint8List());
      await player.setFilePath(file.path);
      // await player.setAsset('assets/sound/barktwice.mp3');
      await player.setLoopMode(LoopMode.off);
      await player.setVolume(1.0);

      audioStream = player.processingStateStream;
      audioStream.listen((ProcessingState event) {
        print('audio event: $event');
        if (event == ProcessingState.completed) {
          player.stop();
          player.seek(Duration.zero);
        }
      });
    });
  }

  _onInit(Artboard art) {
    final ctrl = StateMachineController.fromArtboard(art, 'State Machine 1',
        onStateChange: _onStateChange) as StateMachineController;
    ctrl.isActive = true;
    _bark = ctrl.findInput<bool>('bark');
    _headUp = ctrl.findInput<bool>('Hovering');
    _tilt = ctrl.findInput<bool>('Left Tilt');
    _bark?.value = false;
    art.addController(ctrl);
    _controller = ctrl;
  }

  _onStateChange(String machineName, String state) {
    print('onStateCahnge: $machineName , $state');
    if (state == '100%') {
      player.play();
      setState(() {
        Future.delayed(const Duration(milliseconds: 1900), () {
          _bark?.value = false;
        });
      });
    }
    if (state == 'Tilt Left') {
      setState(() {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _tilt?.value = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('isBark? ${widget.isBark}');
    if (widget.isBark) {
      setState(() {
        _bark?.value = true;
      });
    }
    if (widget.isHeadUp) {
      setState(() {
        _headUp?.value = true;
      });
    }
    if (widget.isHeadDown) {
      setState(() {
        _headUp?.value = false;
      });
    }
    if (widget.isTilt) {
      setState(() {
        _tilt?.value = true;
      });
    }
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 3 / 5,
        child: RiveAnimation.asset(
          'assets/rive/dog_loader.riv',
          onInit: _onInit,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
