import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Nhấn nút và bắt đầu nói...";

  @override
  void initState() {
    super.initState();
    _speechToText.initialize();
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
    });
    _speechToText.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nhập văn bản bằng giọng nói"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _text,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 40,
                color: Colors.blue,
              ),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
          ],
        ),
      ),
    );
  }
}
