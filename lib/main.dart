import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Nhấn nút và nói...";

  // Kiểm tra và yêu cầu quyền microphone
  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();  // Kiểm tra quyền microphone khi app bắt đầu
  }

  // Hàm bắt đầu lắng nghe giọng nói
  void _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    if (available) {
      // Lấy danh sách các ngôn ngữ hỗ trợ
      List<stt.LocaleName> locales = await _speechToText.locales();
      String viLocaleId = 'en_US'; // Ngôn ngữ tiếng Việt

      // Chọn ngôn ngữ tiếng Việt nếu có
      bool isViLocaleAvailable = locales.any((locale) => locale.localeId == viLocaleId);

      if (isViLocaleAvailable) {
        // Bắt đầu nhận diện với ngôn ngữ tiếng Việt
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
          localeId: viLocaleId, // Chỉ định ngôn ngữ tiếng Việt
        );

        setState(() {
          _isListening = true;
          _text = "Đang nghe...";
        });
      } else {
        setState(() {
          _text = "Ngôn ngữ tiếng Việt không khả dụng.";
        });
      }
    } else {
      setState(() {
        _text = "Không thể sử dụng microphone";
      });
    }
  }

  // Hàm dừng lắng nghe giọng nói
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
        title: Text(
          "Nhập văn bản bằng giọng nói",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Hiển thị văn bản nhận diện từ microphone
              SingleChildScrollView(  // Để người dùng có thể cuộn văn bản nếu quá dài
                child: Text(
                  _text,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Colors.pink.shade800,
                    fontFamily: 'DancingScript',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              // Hiển thị biểu tượng mic
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isListening ? 100 : 120,
                width: _isListening ? 100 : 120,
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100,
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    size: 60,
                    color: Colors.white,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
              SizedBox(height: 40),
              AnimatedOpacity(
                opacity: _isListening ? 0.7 : 1.0,
                duration: Duration(milliseconds: 300),
                child: Text(
                  _isListening ? "Đang nghe..." : "Nhấn vào biểu tượng để bắt đầu",
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.pink.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}