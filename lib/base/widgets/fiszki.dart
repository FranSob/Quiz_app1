import 'package:flutter/material.dart';
import 'package:quiz_app1/base/widgets/fiszki_data.dart';

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fiszki',
      home: FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % flashcards.length;
      _showAnswer = false;
    });
  }

  void _toggleCard() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Fiszki'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleCard,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _showAnswer
                        ? card['answer']!
                        : card['question']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextCard,
              child: Text('Następna fiszka'),
            ),
          ],
        ),
      ),
    );
  }
}