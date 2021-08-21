import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'dart:async';
import 'package:talk/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';
import 'room_user.dart';

class Answer extends RoomUser {
  Map<String, dynamic> _iceServers;

  String _offerGender;
  int _offerAge;

  Answer(String udid) {
    this.udid = udid;
  }

  call(Map<String, dynamic> iceServers, Map<String, dynamic> roomData) async {
    _iceServers = iceServers;

    _onListenOffer(roomData);

    snapshotSubscription = Database().onListenTalkRooms((querySnapshot) {
      roomData = _filteringRoom(querySnapshot);
      if (roomData != null) {
        onListen(roomData);
      }
    });
  }

  Map<String, dynamic> _filteringRoom(QuerySnapshot querySnapshot) {
    Map<String, dynamic> result;

    for (final document in querySnapshot.docChanges){

      if (document.type == DocumentChangeType.removed) {
        continue;
      }

      var data = document.doc.data() as Map;

      // 自分のメッセージは無視
      if (data['sender'] == udid) {
        continue;
      }

      // answer側はanswerを無視
      if (data['type'] == 'answer') {
        continue;
      }

      if (session == null) {

        // sessionがない場合はcandidateを無視
        if (data['type'] == 'candidate') {
          continue;
        }

        if (_isMatchSearchSetting(data) == false){
          continue;
        }
      } else {

        // 既にsessionが作られている場合、offerを無視
        if (data['type'] == 'offer') {
          continue;
        }

        // 既にsessionが作られている場合、セッションの部屋以外は無視
        if (data['room_id'] != session.roomId) {
          continue;
        }
      }

      result = data;

      break;
    }

    return result;
  }

  bool _isMatchSearchSetting(Map<String, dynamic> data){

    int offerAge = int.parse(data['offer_age']);

    if (Database().searchMinAge != "なし") {
      int answerSearchMinAge = int.parse(Database().searchMinAge);
      if (answerSearchMinAge > offerAge) {
        return false;
      }
    }

    if (Database().searchMaxAge != "なし") {
      int answerSearchMaxAge = int.parse(Database().searchMaxAge);
      if (answerSearchMaxAge < offerAge) {
        return false;
      }
    }

    int answerAge = int.parse(Database().age);

    if (data['offer_search_age_min'] != "なし") {
      int offerSearchMinAge = int.parse(data['offer_search_age_min']);
      if (offerSearchMinAge > answerAge) {
        return false;
      }
    }

    if (data['offer_search_age_max'] != "なし") {
      int offerSearchMaxAge = int.parse(data['offer_search_age_max']);
      if (offerSearchMaxAge < answerAge) {
        return false;
      }
    }

    String offerGender = data['offer_gender'];

    if (Database().searchGender != "なし") {
      if (Database().searchGender != offerGender) {
        return false;
      }
    }

    String offerSearchGender = data['offer_search_gender'];

    if (offerSearchGender != "なし") {
      if (offerSearchGender != Database().gender) {
        return false;
      }
    }

    return true;
  }

  Future<void> onListen(Map<String, dynamic> data) async {
    switch (data['type']) {
      case 'offer':
        {
          await _onListenOffer(data);
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
    onConnected?.call(_offerGender, _offerAge);
  }

  _onListenOffer(data) async {
    localStream = await createVideoStream();

    session = Session();
    session.roomId = data['room_id'];
    session.offerUDID = data['offer_UDID'];
    session.answerUDID = udid;
    session.peerConnection =
        await createPeerConnection(_iceServers, localStream);

    var descriptionSdp = data['description_sdp'];
    var descriptionType = data['description_type'];

    _offerGender = data['offer_gender'];
    _offerAge = int.parse(data['offer_age']);

    await session.peerConnection.setRemoteDescription(
        rtc.RTCSessionDescription(descriptionSdp, descriptionType));

    rtc.RTCSessionDescription answer =
        await session.peerConnection.createAnswer();
    await session.peerConnection.setLocalDescription(answer);

    await Database().sendTalkRooms(session.roomId, {
      'type': 'answer',
      'room_id': session.roomId,
      'offer_UDID': session.offerUDID,
      'answer_UDID': session.answerUDID,
      'description_sdp': answer.sdp,
      'description_type': answer.type,
      'sender': udid,
      'answer_gender':Database().gender,
      'answer_age':Database().age,
      'offer_gender':_offerGender,
      'offer_age':_offerAge.toString(),
    });

    if (session.remoteCandidates.length > 0) {
      session.remoteCandidates.forEach((candidate) async {
        await session.peerConnection.addCandidate(candidate);
      });
      session.remoteCandidates.clear();
    }
  }
}
