import 'dart:ui';
import 'package:flutter/material.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _animationController.forward(from: 0.0).whenComplete(_onCompleteAnimation);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: _buildAnimation(),
    );
  }

  Widget _buildAnimation() {
    final opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FadeTransition(
                    opacity: opacityAnimation,
                    child: Transform(
                      transform: _generateMatrix(opacityAnimation),
                      child: Text(
                        'Welcome MeTalk!',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  Matrix4 _generateMatrix(Animation animation) {
    final value = lerpDouble(60.0, 0, animation.value);
    return Matrix4.translationValues(0.0, value, 0.0);
  }

  void _onCompleteAnimation() {
    // homeに行くか、プロフィール設定をするか
    Navigator.of(context).pushNamed('/home');
  }
}
