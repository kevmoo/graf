import 'dart:math';
import 'dart:ui' show Offset, Size;

import 'package:graph/graph.dart';

final _rnd = Random();

const _initialDelta = 300;

class NodeSet {
  final _nodes = <String, Node>{};
  final _graph = DirectedGraph<String, dynamic, dynamic>();

  Iterable<Node> get nodes => _nodes.values;

  bool _stable = false;

  bool get stable => _stable;

  NodeSet(int nodeCount) {
    for (var i = 1; i <= nodeCount; i++) {
      var key = i.toString();
      _nodes[key] = Node(key);
      var next = i + 1;
      if (next > nodeCount) {
        next = 1;
      }
      _graph.addEdge(key, next.toString());
    }
    assert(_graph.nodeCount == _nodes.length);
  }

  bool _adjacent(Node a, Node b) => _graph.connected(a.name, b.name);

  Iterable<Pair<Node>> get connectedNodes => _graph.connectedNodes
      .map((p) => Pair<Node>(_nodes[p.item1], _nodes[p.item2]));

  void update(Duration elapsed, Size screenSize) {
    assert(elapsed.inMicroseconds > 0);

    var averageLocation = Offset.zero;

    for (var targetNode in _nodes.values) {
      averageLocation += targetNode._location;

      targetNode.force = Offset.zero;

      for (var otherNode in _nodes.values) {
        if (targetNode == otherNode) {
          continue;
        }

        targetNode.force += _updateForces(
            targetNode, otherNode, _adjacent(targetNode, otherNode));
      }
    }

    // divide the sum of locations by the count of nodes, you get the
    // "average" location of all nodes
    averageLocation *= 1.0 / _nodes.length;

    // apply a small force pushing the global "center" to the middle
    var centeringForce = averageLocation * -0.0001;

    var updates = false;
    for (var targetNode in _nodes.values) {
      targetNode.force += centeringForce;

      updates = targetNode._update(elapsed.inMicroseconds) || updates;
    }

    _stable = !updates;
  }
}

Offset _updateForces(Node targetNode, Node otherNode, bool adjacent) {
  var delta = targetNode.location - otherNode.location;
  var force = delta / delta.distanceSquared;

  if (adjacent) {
    // there's a spring!
    force -= (delta * 0.001);
  }
  return force;
}

class Node implements Comparable<Node> {
  final String name;
  Offset _location = Offset.zero, _velocity = Offset.zero;

  Offset get location => _location;

  Offset get velocity => _velocity;

  Offset force;

  bool _update(int ms) {
    var time = ms / 5000.0;

    _velocity += (force * time);

    // friction
    _velocity *= 0.95;

    if (_velocity.distance > 10) {
      _velocity *= (10 / _velocity.distance);
    }

    if (_velocity.distance < 0.001) {
      _velocity = Offset.zero;
      return false;
    } else {
      _location += (_velocity * time);
      return true;
    }
  }

  Node(this.name)
      : _location = Offset(_initialDelta + _rnd.nextDouble() * _initialDelta,
            _initialDelta + _rnd.nextDouble() * _initialDelta);

  @override
  int compareTo(Node other) => name.compareTo(other.name);
}
