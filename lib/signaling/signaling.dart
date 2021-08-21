import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import 'offer.dart';
import 'answer.dart';
import 'room_user.dart';
import 'package:talk/database/database.dart';

class SignalingArguments {
  final String gender;
  final int age;

  SignalingArguments(this.gender, this.age);
}

class Signaling {
  static Signaling _instance;

  Signaling._();

  factory Signaling() {
    if (_instance == null) {
      _instance = new Signaling._();
    }

    return _instance;
  }

  RoomUser _user;

  String get sdpSemantics => 'unified-plan';
  MediaStream get localStream => _user.localStream;
  MediaStream get remoteStream => _user.remoteStream;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      {'url': 'stun:stun1.l.google.com:19302'},
    ]
  };

  set onDisConnected(StateCallbackDisConnected value) => _user.onDisConnected = value;

  void switchCamera() {
    MediaStreamTrack videoTrack = _user.localStream.getVideoTracks()[0];
    Helper.switchCamera(videoTrack);
  }

  void muteMic() {
    MediaStreamTrack audioTrack = _user.localStream.getAudioTracks()[0];
    bool enabled = audioTrack.enabled;
    audioTrack.enabled = !enabled;
  }

  void offCamera() {
    MediaStreamTrack videoTrack = _user.localStream.getVideoTracks()[0];
    bool enabled = videoTrack.enabled;
    videoTrack.enabled = !enabled;
  }

  Future<void> call(StateCallbackConnected onConnected) async {
    // 検索条件にあったroomをさがす
    final snapshot = await Database().getSnapshotTalkRooms();
    Map<String, dynamic> data;

    for (final document in snapshot.docs){
      data = document.data() as Map;

      // offerは以外は弾く
      if (data["type"] != "offer") {
        data = null;
        continue;
      }

      // 検索設定に合わない場合は弾く
      if (_isMatchSearchSetting(data) == false){
        data = null;
        continue;
      }

      if (data != null){
        break;
      }
    }

    // なければOfferになる
    if (data == null) {
      _user = Offer(Database().udid);
      _user.call(_iceServers, data);
    } else {
      // あればAnswerになる
      _user = Answer(Database().udid);
      _user.call(_iceServers, data);
    }

    _user.onConnected = onConnected;
  }

  bye() async {
    if (_user != null) {
      String roomId = _user.session.roomId;
      await _user.bye();
      await _deleteRoom(roomId);
    }
    _user = null;
  }

  Future<void> _deleteRoom(String roomId) {
    return Database().deleteTalkRoom(roomId);
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
}
