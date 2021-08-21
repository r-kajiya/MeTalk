import 'package:flutter/material.dart';
import 'dart:async';
import '../database/local_database.dart';
import 'dart:core';
import '../util/ads.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:after_layout/after_layout.dart';
import '../terms_of_services.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {
  @override
  void initState() {
    Timer.periodic(
      Duration(seconds: 1),
      _onTimer,
    );

    super.initState();
  }

  void _onTimer(Timer timer) {
    LocalDatabase().secondUpdate();

    setState(() => {});
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (LocalDatabase().isTermsOfService){
      return;
    }
    EasyDialog(closeButton: false, height: 500, contentList: [
      Container(
        child:SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(TermsOfServices.I, style: TextStyle(
            fontSize: 9,
          ),),
        ),
        height: 400,
      ),
      TextButton(
          onPressed: _onPressedTermsOfServices, child: Text("OK")),
    ]).show(context);
  }

  _onPressedTermsOfServices(){
    Navigator.of(context).pop();
    LocalDatabase().applyTermsOfService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: const CallingWidget(),
      persistentFooterButtons: _persistentFooterButtons(),
      backgroundColor: Colors.pink,
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.pinkAccent,
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            heroTag: "hero1",
            child: Icon(Icons.account_circle),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              onPressed: () {
                Navigator.of(context).pushNamed('/search');
              },
              heroTag: "hero2",
              child: Icon(Icons.person_search),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _persistentFooterButtons() {
    return <Widget>[
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _onPressedStamina(0),
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: LocalDatabase().remainingTimeList[0] == 0
                        ? Colors.white
                        : Colors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Text(LocalDatabase().remainingTimeList[0].toString())
                ],
              ),
            ),
            TextButton(
              onPressed: () => _onPressedStamina(1),
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: LocalDatabase().remainingTimeList[1] == 0
                        ? Colors.white
                        : Colors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Text(LocalDatabase().remainingTimeList[1].toString())
                ],
              ),
            ),
            TextButton(
              onPressed: () => _onPressedStamina(2),
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: LocalDatabase().remainingTimeList[2] == 0
                        ? Colors.white
                        : Colors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Text(LocalDatabase().remainingTimeList[2].toString())
                ],
              ),
            ),
            TextButton(
              onPressed: () => _onPressedStamina(3),
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: LocalDatabase().remainingTimeList[3] == 0
                        ? Colors.white
                        : Colors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Text(LocalDatabase().remainingTimeList[3].toString())
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  _onPressedStamina(int index) {
    Ads().loadAndShow(() {
      LocalDatabase().recoverStamina(index);
    });
  }
}

class CallingWidget extends StatelessWidget {
  const CallingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.pink,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ink(
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
                onPressed: () {
                  if (LocalDatabase().canCall()) {
                    Navigator.of(context).pushNamed('/calling');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
