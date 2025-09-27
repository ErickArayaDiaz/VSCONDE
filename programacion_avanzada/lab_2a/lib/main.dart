import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribble Demo',
      home: ScribbleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScribbleScreen extends StatefulWidget {
  @override
  _ScribbleScreenState createState() => _ScribbleScreenState();
}

class _ScribbleScreenState extends State<ScribbleScreen> {
  final ScribbleNotifier _scribbleNotifier = ScribbleNotifier();

  @override
  void dispose() {
    _scribbleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dibujo con Scribble'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _scribbleNotifier.canUndo
                ? _scribbleNotifier.undo
                : null,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _scribbleNotifier.canRedo
                ? _scribbleNotifier.redo
                : null,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _scribbleNotifier.clear,
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Scribble(
            notifier: _scribbleNotifier,
            drawPen: true,
            drawEraser: false,
            background: Container(color: Colors.white),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.brush),
        onPressed: () {
          setState(() {
            final isPen =
                _scribbleNotifier.state.selectedTool == ScribbleTool.pen;
            _scribbleNotifier.setTool(
              isPen ? ScribbleTool.eraser : ScribbleTool.pen,
            );
          });
        },
      ),
    );
  }
}
