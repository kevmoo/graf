import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide TextStyle;

import 'node.dart';

class GraphWidget extends StatefulWidget {
  GraphWidget({Key key, this.nodeCount}) : super(key: key);
  final int nodeCount;

  @override
  _GraphWidgetState createState() => _GraphWidgetState(nodeCount);
}

class _GraphWidgetState extends State<GraphWidget>
    with TickerProviderStateMixin {
  final NodeSet _nodes;
  Ticker _ticker;
  Duration _lastElapsed;
  Duration _delta = const Duration(milliseconds: 17);

  _GraphWidgetState(int nodeCount) : _nodes = NodeSet(nodeCount);

  @override
  void initState() {
    _ticker = createTicker(_onTick)..start();
    print('initState!');
    super.initState();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed != null) {
      assert(elapsed >= _lastElapsed);
      if (elapsed > _lastElapsed) {
        _delta = elapsed - _lastElapsed;
      }
    }
    _lastElapsed = elapsed;

    if (!_nodes.stable) {
      setState(() {
        // noop – just ping the engine!
      });
    } else {
      print('stopped!');
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NodePainter(this._nodes, _delta),
      size: Size.infinite,
      willChange: true,
    );
  }
}

class _NodePainter extends CustomPainter {
  final NodeSet _nodes;
  final Duration _duration;

  _NodePainter(this._nodes, this._duration);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    _nodes.update(_duration, size);

    for (var pair in _nodes.connectedNodes) {
      canvas.drawLine(pair.item1.location, pair.item2.location, _linePaint);
    }

    for (var node in _nodes.nodes) {
      _drawNode(canvas, node);
    }
  }

  void _drawNode(Canvas canvas, Node node) {
    canvas.drawCircle(node.location, 20.0, _paint);

    var builder = ParagraphBuilder(ParagraphStyle(
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
        fontSize: 15.0))
      ..pushStyle(TextStyle(color: Color(0xFF000000)))
      ..addText(node.name);

    var paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: 20.0));

    canvas.drawParagraph(paragraph, node.location.translate(-10.0, -10.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

final _linePaint = Paint()
  ..style = PaintingStyle.stroke
  ..color = Color(0xFFFFD740)
  ..strokeWidth = 2.0;

final _paint = Paint()
  ..style = PaintingStyle.fill
  ..color = Color(0xFFFFC107);
