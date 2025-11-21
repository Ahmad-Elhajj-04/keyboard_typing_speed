import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TypingSpeedApp());
}

class TypingSpeedApp extends StatelessWidget {
  const TypingSpeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TypingTestPage(),
    );
  }
}

class TypingTestPage extends StatefulWidget {
  @override
  State<TypingTestPage> createState() => _TypingTestPageState();
}

class _TypingTestPageState extends State<TypingTestPage> {
  // Difficulty levels
  String difficulty = "Easy";

  final List<String> easySentences = [
    "Flutter makes apps easy.",
    "Typing fast takes practice.",
    "The fox jumps high.",
  ];

  final List<String> mediumSentences = [
    "Programming becomes easier the more you practice it.",
    "Accuracy is more important than raw speed in typing tests.",
    "Flutter is a powerful toolkit for mobile development.",
  ];

  final List<String> hardSentences = [
    "Consistency and dedication are the foundations of true mastery.",
    "Typing complex sentences with punctuation requires focus and skill.",
    "Developers who practice regularly write cleaner and more efficient code.",
  ];

  late String currentSentence;
  final TextEditingController controller = TextEditingController();

  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  double elapsedSeconds = 0.0;
  double wpm = 0.0;
  double accuracy = 0.0;
  bool showResults = false;
  String countdownText = "";

  @override
  void initState() {
    super.initState();
    generateNewSentence();
  }

  // Pick a random sentence based on difficulty
  void generateNewSentence() {
    final random = Random();

    List<String> selectedList;
    if (difficulty == "Easy") {
      selectedList = easySentences;
    } else if (difficulty == "Medium") {
      selectedList = mediumSentences;
    } else {
      selectedList = hardSentences;
    }

    currentSentence = selectedList[random.nextInt(selectedList.length)];

    controller.clear();
    stopwatch.reset();
    elapsedSeconds = 0.0;
    wpm = 0;
    accuracy = 0;
    showResults = false;
    countdownText = "";

    setState(() {});
  }

  // Countdown before typing starts
  Future<void> startCountdown() async {
    countdownText = "3";
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    countdownText = "2";
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    countdownText = "1";
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    countdownText = "Go!";
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 400));

    countdownText = "";
    startTimer();
  }

  void startTimer() {
    if (!stopwatch.isRunning) {
      stopwatch.start();

      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;

          // Update accuracy live
          calculateLiveAccuracy();
        });
      });
    }
  }

  // Live accuracy calculation as user types
  void calculateLiveAccuracy() {
    final typed = controller.text;
    int correctChars = 0;

    for (int i = 0; i < min(typed.length, currentSentence.length); i++) {
      if (typed[i] == currentSentence[i]) correctChars++;
    }

    accuracy = (correctChars / currentSentence.length) * 100;
  }

  // Finish test automatically when full sentence typed
  void checkAutoFinish() {
    if (controller.text.trim() == currentSentence.trim()) {
      finishTest();
    }
  }

  void finishTest() {
    stopwatch.stop();
    timer?.cancel();

    final typed = controller.text.trim();
    final words = typed.split(" ").where((w) => w.isNotEmpty).length;
    final minutes = elapsedSeconds / 60;

    if (minutes > 0) {
      wpm = words / minutes;
    }

    calculateLiveAccuracy();

    setState(() {
      showResults = true;
    });
  }

  // Highlight incorrect characters
  Widget buildHighlightedSentence() {
    List<TextSpan> spans = [];

    String typed = controller.text;

    for (int i = 0; i < currentSentence.length; i++) {
      Color color;

      if (i < typed.length) {
        if (typed[i] == currentSentence[i])
          color = Colors.green;
        else
          color = Colors.red;
      } else {
        color = Colors.black;
      }

      spans.add(TextSpan(
        text: currentSentence[i],
        style: TextStyle(fontSize: 18, color: color),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Typing Speed Tester"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Difficulty Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Difficulty:", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton(
                  value: difficulty,
                  items: ["Easy", "Medium", "Hard"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    difficulty = value!;
                    generateNewSentence();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Highlighted Sentence
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: buildHighlightedSentence(),
            ),

            const SizedBox(height: 20),

            // Countdown text
            if (countdownText.isNotEmpty)
              Text(
                countdownText,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),

            // Typing Box
            TextField(
              controller: controller,
              maxLines: 4,
              autocorrect: false,
              onChanged: (value) {
                if (value.length == 1) {
                  startCountdown();
                }
                calculateLiveAccuracy();
                checkAutoFinish();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type here...",
              ),
            ),

            const SizedBox(height: 20),

            // Live Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Accuracy: ${accuracy.toStringAsFixed(1)}%"),
                Text("Time: ${elapsedSeconds.toStringAsFixed(1)}s"),
              ],
            ),

            const SizedBox(height: 20),

            // Finish Button
            ElevatedButton(
              onPressed: finishTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Finish Test", style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),

            // Final Results
            if (showResults) ...[
              Text("WPM: ${wpm.toStringAsFixed(1)}",
                  style: const TextStyle(fontSize: 18)),
              Text("Accuracy: ${accuracy.toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 18)),
              Text("Time: ${elapsedSeconds.toStringAsFixed(1)}s",
                  style: const TextStyle(fontSize: 18)),
            ],

            const Spacer(),

            // Try Again Button
            ElevatedButton(
              onPressed: generateNewSentence,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Try Again", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
