import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyGameApp());
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Memoria',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const LevelScreen(),
    );
  }
}

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int currentLevel = 0;

  final List<int> levelSizes = [8, 15, 30];

  void goToNextLevel() {
    if (currentLevel < levelSizes.length - 1) {
      setState(() => currentLevel++);
    } else {
      // 🎉 Si ya completó el último nivel → reinicia al nivel 1
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => currentLevel = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nivel ${currentLevel + 1}"),
        centerTitle: true,
      ),
      body: GameBoard(
        totalButtons: levelSizes[currentLevel],
        onLevelCompleted: goToNextLevel,
        isLastLevel: currentLevel == levelSizes.length - 1,
      ),
    );
  }
}

class GameBoard extends StatefulWidget {
  final int totalButtons;
  final VoidCallback onLevelCompleted;
  final bool isLastLevel;

  const GameBoard({
    super.key,
    required this.totalButtons,
    required this.onLevelCompleted,
    required this.isLastLevel,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<int> numbers;
  late List<int> correctOrder;
  int? firstSelectedIndex;
  int moves = 0;
  int seconds = 0;
  Timer? timer;
  bool completed = false;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    numbers = List.generate(widget.totalButtons, (i) => i + 1)..shuffle();
    correctOrder = List.generate(widget.totalButtons, (i) => i + 1);
    moves = 0;
    seconds = 0;
    completed = false;
    firstSelectedIndex = null;
    timer?.cancel();
    setState(() {});
  }

  void startTimer() {
    timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!completed) {
        setState(() {
          seconds++;
        });
      }
    });
  }

  void selectButton(int index) {
    if (completed) return;

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      setState(() {
        final temp = numbers[firstSelectedIndex!];
        numbers[firstSelectedIndex!] = numbers[index];
        numbers[index] = temp;
        moves++;
        firstSelectedIndex = null;
        startTimer();
      });
      checkCompletion();
    }
  }

  void checkCompletion() {
    if (numbers.join(",") == correctOrder.join(",")) {
      setState(() {
        completed = true;
        timer?.cancel();
      });

      // ⏳ Un pequeño delay para mostrar el mensaje antes de cambiar nivel
      Future.delayed(const Duration(seconds: 1), widget.onLevelCompleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount;
    if (widget.totalButtons <= 8) {
      crossAxisCount = 4; // 8 botones → 2x4
    } else if (widget.totalButtons <= 14) {
      crossAxisCount = 5; // 14 botones → ~3x5
    } else {
      crossAxisCount = 5; // 25 botones → 5x5
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            "⏱ Tiempo: $seconds s",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "🔄 Movimientos: $moves",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                final value = numbers[index];
                final isCorrect = value == correctOrder[index];
                return GestureDetector(
                  onTap: () => selectButton(index),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$value",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: resetGame, child: const Text("🔄 Reset")),
          if (completed)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.isLastLevel
                    ? "🏆 ¡Juego completado! Reiniciando..."
                    : "✅ ¡Nivel completado!",
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}
