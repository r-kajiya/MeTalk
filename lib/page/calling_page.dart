import 'package:flutter/material.dart';
import 'package:talk/signaling/signaling.dart';

class CallingPage extends StatefulWidget {
  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);

    Signaling().call((String gender, int age) {
      Navigator.of(context).pushNamed('/standby', arguments: SignalingArguments(gender, age));
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text('Calling'),
        ),
        backgroundColor: Colors.pink,
        body: _buildAnimation(),
      ),
    );
  }

  Future<bool> _onWillPop() {
    Signaling().bye();
    return Future.value(true);
  }

  Widget _buildAnimation() {
    return Center(
      child: ScaleTransition(
          scale: _animationController.drive(
            Tween<double>(
              begin: 1,
              end: 2,
            ),
          ),
          child: Ink(
            decoration: const ShapeDecoration(
              color: Colors.white,
              shadows: [
                BoxShadow(
                    color: Colors.black26, spreadRadius: 10, blurRadius: 15)
              ],
              shape: CircleBorder(
                  side: BorderSide(
                width: 20,
                style: BorderStyle.none,
              )),
            ),
            child: IconButton(
              iconSize: 70,
              icon: const Icon(Icons.call),
              color: Colors.pink,
            ),
          )),
    );
  }
}
