import 'package:flutter_webrtc/flutter_webrtc.dart';

class Session {
  Session();
  String roomId;
  String offerUDID;
  String answerUDID;
  RTCPeerConnection peerConnection;
  List<RTCIceCandidate> remoteCandidates = [];
}
