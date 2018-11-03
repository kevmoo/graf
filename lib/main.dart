import 'package:flutter/widgets.dart';

import 'graph_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphWidget(nodeCount: 20);
  }
}
