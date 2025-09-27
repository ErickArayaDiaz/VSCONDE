import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() => runApp(PizarraApp());

class PizarraApp extends StatelessWidget {
  const PizarraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizarra Flutter',
      debugShowCheckedModeBanner: false,
      home: PizarraPage(),
    );
  }
}

class DrawPoint {
  final Offset point;
  final Paint paint;

  DrawPoint({required this.point, required this.paint});
}

class PizarraPage extends StatefulWidget {
  const PizarraPage({super.key});

  @override
  _PizarraPageState createState() => _PizarraPageState();
}

class _PizarraPageState extends State<PizarraPage> {
  final List<DrawPoint?> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false;

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  void _toggleEraser() {
    setState(() {
      _isEraser = !_isEraser;
    });
  }

  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
      _isEraser = false; // Desactiva el borrador si cambia color
    });
  }

  void _changeStrokeWidth(double value) {
    setState(() {
      _strokeWidth = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pizarra Flutter'),
        backgroundColor: _isEraser ? Colors.red[400] : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Borrar todo',
            onPressed: _clearCanvas,
          ),
          IconButton(
            icon: Icon(_isEraser ? Icons.brush : Icons.clear),
            tooltip: _isEraser ? 'Modo dibujar' : 'Modo borrar',
            onPressed: _toggleEraser,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset point = renderBox.globalToLocal(details.globalPosition);

                Paint paint = Paint()
                  ..color = _isEraser ? Colors.white : _selectedColor
                  ..strokeWidth = _strokeWidth
                  ..strokeCap = StrokeCap.round;

                setState(() {
                  _points.add(DrawPoint(point: point, paint: paint));
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _points.add(null); // separador entre trazos
                });
              },
              child: CustomPaint(
                painter: PizarraPainter(points: _points),
                size: Size.infinite,
              ),
            ),
          ),
          SizedBox(height: 10),
          _buildColorPicker(),
          _buildStrokeSlider(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.brown,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors
          .map(
            (color) => GestureDetector(
              onTap: () => _changeColor(color),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color ? Colors.white : Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStrokeSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text('Tamaño:'),
          Expanded(
            child: Slider(
              value: _strokeWidth,
              min: 1.0,
              max: 20.0,
              activeColor: _selectedColor,
              label: _strokeWidth.toStringAsFixed(1),
              onChanged: (value) => _changeStrokeWidth(value),
            ),
          ),
        ],
      ),
    );
  }
}

class PizarraPainter extends CustomPainter {
  final List<DrawPoint?> points;

  PizarraPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      if (p1 != null && p2 != null) {
        canvas.drawLine(p1.point, p2.point, p1.paint);
      } else if (p1 != null && p2 == null) {
        canvas.drawPoints(ui.PointMode.points, [p1.point], p1.paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
