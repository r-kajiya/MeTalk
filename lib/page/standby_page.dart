import 'package:flutter/material.dart';
import 'package:talk/signaling/signaling.dart';

class StandbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final SignalingArguments args = ModalRoute.of(context).settings.arguments;

    return WillPopScope(
      onWillPop: ()=>_onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text('Standby'),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _gender(args.gender),
              _age(args.age.toString()),
              _connect(context),
            ]),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) {
    Signaling().bye();
    Navigator.of(context).pushNamed('/home');
    return Future.value(true);
  }

  Row _gender(String gender) {
    return Row(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(5.0),
      ),
      Text("性別：" + gender),
    ]);
  }

  Row _age(String age) {
    return Row(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(5.0),
      ),
      Text("年齢：" + age),
    ]);
  }

  Padding _connect(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(60.0),
      child: ElevatedButton(
        child: const Text('OK'),
        style: ElevatedButton.styleFrom(
          primary: Colors.pinkAccent,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _onPressedConnect(context);
        },
      ),
    );
  }

  _onPressedConnect(BuildContext context) {
    Navigator.of(context).pushNamed('/talk');
  }
}
