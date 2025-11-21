import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typing Speed Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TypingTestPage(),
    );
  }
}

class TypingTestPage extends StatefulWidget {
  const TypingTestPage({super.key});

  @override
  State<TypingTestPage> createState() => _TypingTestPageState();
}

class _TypingTestPageState extends State<TypingTestPage> {
  final TextEditingController _textController = TextEditingController();
  final String _targetText = "The quick brown fox jumps over the lazy dog";
  String _typedText = "";
  int _startTime = 0;
  int _elapsedTime = 0;
  bool _isTyping = false;
  bool _isFinished = false;
  Timer? _timer;
  int _countdown = 0;
  bool _isCountdownActive = false;
  
  int _correctChars = 0;
  int _totalChars = 0;
  int _errors = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_isCountdownActive && !_isFinished) {
      setState(() {
        _typedText = _textController.text;
        _calculateAccuracy();
        _checkAutoFinish();
      });
    }
  }

  void _calculateAccuracy() {
    _totalChars = _typedText.length;
    _correctChars = 0;
    _errors = 0;

    for (int i = 0; i < _typedText.length; i++) {
      if (i < _targetText.length) {
        if (_typedText[i] == _targetText[i]) {
          _correctChars++;
        } else {
          _errors++;
        }
      } else {
        _errors++;
      }
    }
  }

  double get _accuracy {
    if (_totalChars == 0) return 100.0;
    return (_correctChars / _totalChars) * 100;
  }

  int get _wordsTyped {
    if (_typedText.trim().isEmpty) return 0;
    return _typedText.trim().split(RegExp(r'\s+')).length;
  }

  int get _targetWords {
    return _targetText.trim().split(RegExp(r'\s+')).length;
  }

  void _checkAutoFinish() {
    if (_typedText.trim() == _targetText.trim() && _isTyping) {
      _finishTest();
    }
  }

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdown = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
          _isCountdownActive = false;
          _startTest();
        }
      });
    });
  }

  void _startTest() {
    setState(() {
      _isTyping = true;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      _elapsedTime = 0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isFinished) {
        setState(() {
          _elapsedTime = DateTime.now().millisecondsSinceEpoch - _startTime;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _finishTest() {
    setState(() {
      _isFinished = true;
      _isTyping = false;
    });
    _timer?.cancel();
  }

  void _resetTest() {
    setState(() {
      _textController.clear();
      _typedText = "";
      _isTyping = false;
      _isFinished = false;
      _elapsedTime = 0;
      _countdown = 0;
      _isCountdownActive = false;
      _correctChars = 0;
      _totalChars = 0;
      _errors = 0;
    });
    _timer?.cancel();
  }

  double get _wpm {
    if (_elapsedTime == 0) return 0.0;
    double minutes = _elapsedTime / 60000.0;
    return (_wordsTyped / minutes);
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];
    
    for (int i = 0; i < _targetText.length; i++) {
      Color color;
      Color? backgroundColor;
      
      if (i < _typedText.length) {
        if (_typedText[i] == _targetText[i]) {
          color = Colors.green;
        } else {
          color = Colors.red;
          backgroundColor = Colors.red.withOpacity(0.2);
        }
      } else if (i == _typedText.length) {
        color = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
      } else {
        color = Colors.grey;
      }
      
      spans.add(TextSpan(
        text: _targetText[i],
        style: TextStyle(
          color: color,
          backgroundColor: backgroundColor,
          fontSize: 20,
          fontWeight: i == _typedText.length ? FontWeight.bold : FontWeight.normal,
        ),
      ));
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Speed Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Row
              if (!_isCountdownActive && (_isTyping || _isFinished))
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'WPM',
                        value: _wpm.toStringAsFixed(0),
                        icon: Icons.speed,
                      ),
                      _StatItem(
                        label: 'Accuracy',
                        value: '${_accuracy.toStringAsFixed(1)}%',
                        icon: Icons.check_circle,
                      ),
                      _StatItem(
                        label: 'Time',
                        value: _formatTime(_elapsedTime),
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                ),
              
              if (!_isCountdownActive && (_isTyping || _isFinished))
                const SizedBox(height: 16),
              
              // Word Count Indicator
              if (!_isCountdownActive && (_isTyping || _isFinished))
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Words: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '$_wordsTyped / $_targetWords',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (!_isCountdownActive && (_isTyping || _isFinished))
                const SizedBox(height: 24),
              
              // Countdown Display
              if (_isCountdownActive)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_countdown',
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Get ready!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Target Text Display
              if (!_isCountdownActive)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: _buildTextSpans(),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              
              if (!_isCountdownActive)
                const SizedBox(height: 24),
              
              // Text Input
              if (!_isCountdownActive && !_isFinished)
                TextField(
                  controller: _textController,
                  autofocus: true,
                  enabled: _isTyping,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _isTyping 
                        ? 'Start typing...' 
                        : 'Click "Start Test" to begin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16.0),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              
              if (!_isCountdownActive && _isFinished)
                const SizedBox(height: 24),
              
              // Results Display
              if (!_isCountdownActive && _isFinished)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Test Complete!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You typed ${_wordsTyped} words in ${_formatTime(_elapsedTime)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              if (!_isCountdownActive)
                Row(
                  children: [
                    if (!_isTyping && !_isFinished)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startCountdown,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Test'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (_isTyping && !_isFinished)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _finishTest,
                          icon: const Icon(Icons.stop),
                          label: const Text('Finish Test'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (_isFinished)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetTest,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
