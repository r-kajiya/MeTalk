import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'dart:async';
import 'package:talk/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';
import 'room_user.dart';

class Offer extends RoomUser {

  String _answerGender;
  int _answerAge;

  Offer(String udid) {
    this.udid = udid;
  }

  call(Map<String, dynamic> iceServers, Map<String, dynamic> roomData) async {
    // 自分のカメラを作る
    localStream = await createVideoStream();

    // セッションを作る
    session = Session();
    session.roomId = udid;
    session.offerUDID = udid;
    session.answerUDID = null;
    session.peerConnection =
        await createPeerConnection(iceServers, localStream);

    // オファーを設定する
    rtc.RTCSessionDescription offer =
        await session.peerConnection.createOffer();
    await session.peerConnection.setLocalDescription(offer);

    // 部屋を作る(オファーする)
    await Database().sendTalkRooms(session.roomId, {
      'type': 'offer',
      'room_id': session.roomId,
      'offer_UDID': session.offerUDID,
      'answer_UDID': session.answerUDID,
      'description_sdp': offer.sdp,
      'description_type': offer.type,
      'offer_age' : Database().age,
      'offer_gender' : Database().gender,
      'offer_search_age_min' : Database().searchMinAge,
      'offer_search_age_max' : Database().searchMaxAge,
      'offer_search_gender' : Database().searchGender,
    });

    // 作ったあとは条件に当てはまる人が来るまで監視
    snapshotSubscription = Database().onListenTalkRooms((querySnapshot) {
      var roomData = _filteringRoom(querySnapshot);
      if (roomData != null) {
        onListen(roomData);
      }
    });
  }

  Map<String, dynamic> _filteringRoom(QuerySnapshot querySnapshot) {
    Map<String, dynamic> result;

    for (final changes in querySnapshot.docChanges) {
      if (changes.type == DocumentChangeType.removed) {
        continue;
      }

      var data = changes.doc.data() as Map;

      // 自分の部屋以外は無視
      if (data['room_id'] != session.roomId) {
        continue;
      }

      // 自分のメッセージは無視
      if (data['sender'] == udid) {
        continue;
      }

      // offer側はofferを無視
      if (data['type'] == 'offer') {
        continue;
      }

      result = data;
      break;
    }

    return result;
  }

  Future<void> onListen(Map<String, dynamic> data) async {
    switch (data['type']) {
      case 'answer':
        {
          await _onListenAnswer(data);
          break;
        }
      case 'candidate':
        {
          await onListenCandidate(data);
          break;
        }
    }
  }

  onConnectionStateConnected(){
    onConnected?.call(_answerGender, _answerAge);
  }

  _onListenAnswer(data) async {
    var descriptionSdp = data['description_sdp'];
    var descriptionType = data['description_type'];
    session.peerConnection.setRemoteDescription(
        rtc.RTCSessionDescription(descriptionSdp, descriptionType));

    _answerGender = data['answer_gender'];
    _answerAge = int.parse(data['answer_age']);

    // 溜まったcandidateをわたす
    candidateList.forEach((candidate) {
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
    });
  }
}
