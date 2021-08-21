import 'session.dart';
import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:talk/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef void StateCallbackConnected(String gender, int age);
typedef void StateCallbackDisConnected();

abstract class RoomUser {
  StreamSubscription<QuerySnapshot> snapshotSubscription;
  String udid;
  Session session;
  rtc.MediaStream localStream;
  rtc.MediaStream remoteStream;
  StateCallbackConnected onConnected;
  StateCallbackDisConnected onDisConnected;
  List<rtc.RTCIceCandidate> candidateList = [];
  String get sdpSemantics => 'unified-plan';

  Future<void> onListen(Map<String, dynamic> data);

  call(Map<String, dynamic> iceServers, Map<String, dynamic> roomData);

  bye() async {
    if (localStream != null) {
      localStream.getTracks().forEach((element) async {
        element.stop();
      });
      await localStream.dispose();
      localStream = null;
    }

    if (session != null) {
      await session.peerConnection?.close();
      session = null;
    }

    snapshotSubscription?.cancel();
  }

  Future<rtc.RTCPeerConnection> createPeerConnection(
      Map<String, dynamic> iceServers, rtc.MediaStream localStream) async {
    rtc.RTCPeerConnection peerConnection = await rtc.createPeerConnection({
      ...iceServers,
      ...{'sdpSemantics': sdpSemantics}
    });

    peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        remoteStream = event.streams[0];
      }
    };

    localStream.getTracks().forEach((track) {
      peerConnection.addTrack(track, localStream);
    });

    peerConnection.onIceCandidate = _onIceCandidate;
    peerConnection.onConnectionState = _onConnectionState;

    return peerConnection;
  }

  _onIceCandidate(rtc.RTCIceCandidate candidate) {
    if (candidate == null) {
      return;
    }

    if (session == null) {
      return;
    }

    if (session.answerUDID == null || session.offerUDID == null) {
      if (session.peerConnection != null) {
        session.peerConnection.addCandidate(candidate);
      } else {
        session.remoteCandidates.add(candidate);
      }

      candidateList.add(candidate);
      return;
    }

    Database().sendTalkRooms(session.roomId, {
      'type': 'candidate',
      'room_id': session.roomId,
      'offer_UDID': session.offerUDID,
      'answer_UDID': session.answerUDID,
      'candidate': candidate.candidate,
      'candidate_sdp_MLine_index': candidate.sdpMlineIndex,
      'candidate_sdp_mid': candidate.sdpMid,
      'sender': udid,
    });
  }

  _onConnectionState(rtc.RTCPeerConnectionState state) {
    if (state == rtc.RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      onConnectionStateConnected();
      onConnected = null;
      snapshotSubscription?.cancel();
    }

    if (state ==
        rtc.RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      onDisConnected?.call();
      onDisConnected = null;
    }
  }

  onConnectionStateConnected();

  Future<rtc.MediaStream> createVideoStream() async {
    final Map<String, dynamic> mediaContains = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '1280',
          'minHeight': '720',
          'minFrameRate': '30'
        },
        'facingMode': 'environment'
      },
      'facingMode': 'environment',
      'optional': []
    };

    return await rtc.navigator.mediaDevices.getUserMedia(mediaContains);
  }

  Future<void> onListenCandidate(data) async {
    rtc.RTCIceCandidate candidate = rtc.RTCIceCandidate(data['candidate'],
        data['candidate_sdp_mid'], data['candidate_sdp_MLine_index']);

    if (session.peerConnection != null) {
      await session.peerConnection.addCandidate(candidate);
    } else {
      session.remoteCandidates.add(candidate);
    }
  }
}
