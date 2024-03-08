import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:stt_rive_sample/rive.dart';

class Stt extends StatefulWidget {
  const Stt({Key? key}) : super(key: key);

  @override
  State<Stt> createState() => _SttState();
}

class _SttState extends State<Stt> {
  var text = "Hold the button and start speaking";
  var isListening = false;
  Color bgColor = const Color(0xff00A67E);

  stt.SpeechToText speechToText = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    checkMicrophoneAvailability();
  }

  void checkMicrophoneAvailability() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        if (kDebugMode) {
          print('Microphone available: $available');
        }
      });
    } else {
      if (kDebugMode) {
        print("The user has denied the use of speech recognition.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        duration: const Duration(milliseconds: 2000),
        glowColor: bgColor,
        repeat: true,
        child: GestureDetector(
          onTap: () async {
            if (!isListening) {
              var available = await speechToText.initialize(debugLogging: true);
              if (available) {
                setState(() {
                  isListening = true;
                });
                speechToText.listen(
                    listenFor: const Duration(days: 1),
                    onResult: (result) {
                      setState(() {
                        text = result.recognizedWords;
                      });
                    });
              }
            } else {
              setState(() {
                isListening = false;
              });
              speechToText.stop();
            }
          },
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 30,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_off,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // unfocus the text when user taps outside the container
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              RivePage(
                isBark: text == '멍멍',
                isHeadDown: text == '앉아',
                isHeadUp: text == '일어서',
                isTilt: text != '멍멍' &&
                    text != '앉아' &&
                    text != '일어서' &&
                    text != "Hold the button and start speaking",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          text = '멍멍';
                        });
                      },
                      child: const Text('멍멍')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          text = '앉아';
                        });
                      },
                      child: const Text('앉아')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          text = '일어서';
                        });
                      },
                      child: const Text('일어서')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          text = '산책';
                        });
                      },
                      child: const Text('산책?')),
                ],
              ),
              const SizedBox(height: 20),
              SelectableText(
                text,
                style: TextStyle(
                    fontSize: 18,
                    color: isListening ? Colors.black87 : Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
