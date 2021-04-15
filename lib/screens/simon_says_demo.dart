import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class AnimatedShape extends StatefulWidget {
  final String _name;
  final Color _color;
  final bool _disable;
  final Function onClick;
  AnimatedShape(this._name, this._color, this._disable, this.onClick);

  Color getColor() {
    return this._color;
  }

  String getName() {
    return this._name;
  }

  @override
  _AnimatedShapeState createState() => _AnimatedShapeState();
}

class _AnimatedShapeState extends State<AnimatedShape>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double _scale;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 100,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _tapDown(TapDownDetails details) {
    if (!widget._disable) {
      _controller.forward();
      widget.onClick();
    }
  }

  void _tapUp(TapUpDetails details) {
    if (!widget._disable) {
      _controller.reverse();
    }
  }

  double _width = 100;
  double _height = 100;

  Widget _getChild() {
    switch (widget._name) {
      case 'Square':
        return Container(
          width: _width,
          height: _height,
          margin: const EdgeInsets.all(10),
          color: widget._color,
        );
      default:
        return ErrorWidget('Shape Not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
        onTapDown: _tapDown,
        onTapUp: _tapUp,
        child: Transform.scale(scale: _scale, child: _getChild()));
  }
}

class SimonSaysDemo extends StatefulWidget {
  @override
  _SimonSaysDemoState createState() => _SimonSaysDemoState();
}

class _SimonSaysDemoState extends State<SimonSaysDemo> {
  List<int> _pattern = [];
  Color _color;
  List<int> _guesses = [];
  int _numberOfTrys = 3;
  bool _showColor = true;
  List<AnimatedShape> _shapes = [];

  List<AnimatedShape> _makeShapes(bool disabled) {
    return [
      AnimatedShape('Square', Colors.amber, disabled, () => onClick(0)),
      AnimatedShape('Square', Colors.teal, disabled, () => onClick(1)),
      AnimatedShape('Square', Colors.pink, disabled, () => onClick(2)),
      AnimatedShape('Square', Colors.lime, disabled, () => onClick(3)),
    ];
  }

  Future<void> _randomShapeIndex() async {
    if (_pattern.length > 0)
      await Future.delayed(
        Duration(seconds: 1),
      );
    final int _random = Random().nextInt(_shapes.length);
    setState(() {
      _pattern += [_random];
    });

    setState(() {
      _shapes = _makeShapes(true);
      _showColor = true;
    });

    for (var index in _pattern) {
      setState(() {
        _color = _shapes[index]._color;
      });
      await Future.delayed(
        Duration(seconds: 1),
      );
    }
    setState(() {
      _shapes = _makeShapes(false);
      _showColor = false;
    });
    print(_pattern);
  }

  void _initialize() {
    if (_shapes.length <= 0) {
      setState(() {
        _shapes = _makeShapes(true);
      });
    }
  }

  void onClick(int guess) {
    var newGuessList = _guesses + [guess];
    var currentGuessIndex = newGuessList.length - 1;
    print(newGuessList);
    if (guess != _pattern[currentGuessIndex]) {
      setState(() {
        _numberOfTrys -= 1;
        _guesses = [];
      });
    } else {
      if (newGuessList.length == _pattern.length) {
        setState(() {
          _guesses = [];
        });
        _randomShapeIndex();
      } else {
        setState(() {
          _guesses = newGuessList;
        });
      }
    }
    if (_numberOfTrys == 0) {
      _shapes = _makeShapes(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.green,
      backgroundColor: Colors.green,
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Layout Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
        children: [
          if (_shapes.length > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shapes[0],
                _shapes[1],
              ],
            ),
          if (_shapes.length > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shapes[2],
                _shapes[3],
              ],
            ),
          if (_pattern.length > 0)
            Column(children: [
              Text(_showColor
                  ? 'The Pattern'
                  : _numberOfTrys == 0
                      ? 'Game Over'
                      : 'Your Turn'),
              if (!_showColor)
                Text('Remaining Guesses: ' + _numberOfTrys.toString()),
              if (_showColor)
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(10),
                  color: _color,
                )
            ]),
          if (_pattern.length < 1)
            ElevatedButton(
                onPressed: _randomShapeIndex,
                child: Text(
                  'Start Game',
                  style: TextStyle(color: Colors.white),
                ),
                style: flatButtonStyle)
        ],
      ),
    );
  }
}
