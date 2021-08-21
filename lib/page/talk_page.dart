import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:talk/signaling/signaling.dart';
import 'package:talk/log/talk_logger.dart';
import '../database/local_database.dart';

class TalkPage extends StatefulWidget {
  static String tag = 'TalkPage';

  TalkPage({Key key}) : super(key: key);

  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  _TalkPageState();

  @override
  initState() {
    super.initState();
    initRenderers();
    Signaling().onDisConnected = () {
      Navigator.of(context).pushNamed('/home');
      LocalDatabase().depletesStamina();
    };
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    setState(() {
      _localRenderer.srcObject = Signaling().localStream;
      _remoteRenderer.srcObject = Signaling().remoteStream;
    });
  }

  @override
  deactivate() {
    super.deactivate();
    Signaling().bye();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  _hangUp() {
    Navigator.of(context).pushNamed('/home');
    Signaling().onDisConnected = null;
    Signaling().bye();
    LocalDatabase().depletesStamina();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
            width: 250.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    child: const Icon(Icons.switch_camera),
                    onPressed: () {
                      Signaling().switchCamera();
                      setState(() {
                        _remoteRenderer.srcObject = Signaling().remoteStream;
                      });
                    },
                    backgroundColor: Colors.pink,
                    heroTag: "hero1",
                  ),
                  FloatingActionButton(
                    onPressed: _hangUp,
                    tooltip: 'Hangup',
                    child: Icon(Icons.call_end),
                    backgroundColor: Colors.pink,
                    heroTag: "hero2",
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.mic_off),
                    onPressed: Signaling().muteMic,
                    backgroundColor: Colors.pink,
                    heroTag: "hero3",
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.camera_alt),
                    onPressed: Signaling().offCamera,
                    backgroundColor: Colors.pink,
                    heroTag: "hero4",
                  )
                ])),
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
            child: Stack(children: <Widget>[
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: RTCVideoView(_remoteRenderer),
                    decoration: BoxDecoration(color: Colors.black54),
                  )),
              Positioned(
                left: 20.0,
                top: 20.0,
                child: Container(
                  width: orientation == Orientation.portrait ? 108.0 : 144.0,
                  height: orientation == Orientation.portrait ? 144.0 : 108.0,
                  child: RTCVideoView(_localRenderer, mirror: true),
                  decoration: BoxDecoration(color: Colors.black54),
                ),
              ),
            ]),
          );
        }));
  }
}
