import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quiz_app1/base/widgets/fiszki_data.dart';

class QuizFiszkiPage extends StatefulWidget {
  final List<Fiszka> fiszki;
  final String? folderName;
  const QuizFiszkiPage({super.key, required this.fiszki, this.folderName});

  @override
  State<QuizFiszkiPage> createState() => _QuizFiszkiPageState();
}

class _QuizFiszkiPageState extends State<QuizFiszkiPage> {
  int currentIndex = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    // losowa kolejność - jeśli chcesz stałą kolejność, usuń tę linię
    widget.fiszki.shuffle(Random());
  }

  void goNext() {
    if (currentIndex < widget.fiszki.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    } else {
      _showFinishedDialog();
    }
  }

  void goPrev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  void flipFiszka() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

void exitQuiz({required bool finished}) {
  // zamknij WSZYSTKO (dialog + quiz) i wróć do folderów
  Navigator.of(context).pop(finished);
}

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Koniec fiszek'),
        content: const Text('Przeglądałeś wszystkie fiszki. Co chcesz zrobić dalej?'),
        actions: [
          // Zamknij -> tylko zamyka dialog, pozostajesz na stronie quizu
          TextButton(
            onPressed: () {
              Navigator.pop(context); // zamknij dialog
            },
            child: const Text('Zamknij'),
          ),
          // Restartuj -> zamyka dialog i restartuje quiz
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // zamknij dialog
              setState(() {
                currentIndex = 0;
                showAnswer = false;
                widget.fiszki.shuffle(Random()); // możesz usunąć, jeśli nie chcesz reshuffle
              });
            },
            child: const Text('Restartuj'),
          ),
          // Zakończ -> zakończ quiz i wróć do strony z folderami, zwracając true
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context); // zamknij dialog
              Navigator.pop(context, true); // wróć do folderów i zwróć true
            },
            child: const Text('Zakończ'),
          ),
        ],
      ),
    );
  }

  // Animowany flip: używamy AnimatedSwitcher z rotacją Y transform
 Widget _buildFlipCard(Fiszka fiszka) {
  return GestureDetector(
    onTap: flipFiszka,
    child: TweenAnimationBuilder<double>(
      key: ValueKey(currentIndex), // każda fiszka ma unikalny key
      tween: Tween<double>(begin: 0, end: showAnswer ? 1 : 0),
      duration: const Duration(milliseconds: 450),
      builder: (context, val, child) {
        final angle = val * pi;
        final isFront = val <= 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspektywa 3D
            ..rotateY(angle),
          child: isFront
              ? _CardFace(
                  key: ValueKey('front_$currentIndex'),
                  text: fiszka.question,
                  smallText: 'Tap to flip',
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: _CardFace(
                    key: ValueKey('back_$currentIndex'),
                    text: fiszka.answer,
                    smallText: 'Tap to flip',
                  ),
                ),
        );
      },
    ),
  );
}



  // Obsługa swipeów
  void _onHorizontalDragEnd(DragEndDetails details) {
    final vx = details.primaryVelocity ?? 0.0;
    if (vx < -300) {
      // swipe left -> next
      goNext();
    } else if (vx > 300) {
      // swipe right -> prev
      goPrev();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fiszki.isEmpty) {
      return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        foregroundColor: Colors.white, // wymusza biały kolor ikon i tekstu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz Fiszek',
          style: TextStyle(color: Colors.white),
        ),
      ),

        body: const Center(
          child: Text(
            'Brak fiszek. Dodaj najpierw fiszki!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final currentFiszka = widget.fiszki[currentIndex];
    final total = widget.fiszki.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(110),
  child: AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2B3D),
            Color(0xFF1C1C28),
          ],
        ),
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Fiszek',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(28),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          '${currentIndex + 1} / $total',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  ),
),

      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: _onHorizontalDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              const SizedBox(height: 28),
              // progress indicator (subtle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / total,
                  backgroundColor: Colors.white12,
                  color: Colors.deepPurple,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),

              // CARD: centered with responsive size
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                        maxHeight: 420,
                        minHeight: 220,
                      ),
                      child: _CardContainer(
                        child: _buildFlipCard(currentFiszka),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // navigation controls (prev / index / next)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Prev
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onPressed: currentIndex > 0 ? goPrev : null,
                    ),
                    const SizedBox(width: 18),
                    // Index bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C28),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        '${currentIndex + 1} / $total',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Next
                    _CircleIconButton(
                      icon: Icons.arrow_forward,
                      onPressed: currentIndex < total - 1 ? goNext : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

             Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
  child: Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
  backgroundColor: currentIndex == total - 1
      ? Colors.redAccent
      : const Color(0xFF0F0F14), // kolor tła aplikacji
  elevation: currentIndex == total - 1 ? 2 : 0, // brak „wypukłości” dla Porzuć
  side: currentIndex == total - 1
      ? null
      : const BorderSide(color: Colors.white24), // delikatna ramka
  padding: const EdgeInsets.symmetric(vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
),

          onPressed: () {
  if (currentIndex == total - 1) {
    // ostatnia fiszka → zakończ quiz
    exitQuiz(finished: true);
  } else {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Porzucić quiz?'),
        content: const Text('Czy na pewno chcesz wrócić do folderów?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.pop(dialogContext); // zamknij dialog
              exitQuiz(finished: false);    // wyjdź z quizu
            },
            child: const Text('Porzuć'),
                  ),

                    
                  ],
                ),
              );
            }
          },
          child: Text(
            currentIndex == total - 1 ? 'ZAKOŃCZ' : 'PORZUĆ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            currentIndex = 0;
                            showAnswer = false;
                            widget.fiszki.shuffle(Random());
                          });
                        },
                        child: const Text(
                          'RESTART',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

/// small reusable widget for circle arrow buttons
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _CircleIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? Colors.deepPurple : Colors.white10,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(color: Colors.black.withOpacity(0.45), offset: const Offset(3, 4), blurRadius: 8),
                  BoxShadow(color: Colors.white.withOpacity(0.03), offset: const Offset(-3, -2), blurRadius: 4),
                ]
              : null,
        ),
        child: Icon(icon, color: enabled ? Colors.white : Colors.white38),
      ),
    );
  }
}

/// Card container adds elevation, rounded corners and subtle gradient
class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -1),
          end: Alignment(0.8, 1),
          colors: [
            Color(0xFF15151A),
            Color(0xFF0F0F14),
          ],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 18, offset: const Offset(0, 12)),
          BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 2, offset: const Offset(-2, -2)),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),
    );
  }
}

/// Card face: used for front (question) and back (answer)
class _CardFace extends StatelessWidget {
  final String text;
  final String? smallText;

  const _CardFace({super.key, required this.text, this.smallText});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      color: const Color(0xFF1C1C28),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.28),
              ),
            ),
          ),
          if (smallText != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                smallText!,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
