import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'dart:async';
import 'local_database.dart';

class Database {
  static Database _instance;

  Database._();

  factory Database() {
    if (_instance == null) {
      _instance = new Database._();
    }

    return _instance;
  }

  final String usersDB = "users";
  final String talkRoomDB = "talk_rooms";
  String udid;

  String gender;
  String age;
  String searchGender;
  String searchMinAge;
  String searchMaxAge;

  Future<void> setup() async {
    udid = await FlutterUdid.consistentUdid;
    await Firebase.initializeApp();
    await _createUserData();
    await deleteTalkRoom(udid);
  }

  Future<void> sendTalkRooms(String document, data) async {
    return await send(talkRoomDB, document, data);
  }

  Future<void> sendUsers(String document, data) async {
    return await send(usersDB, document, data);
  }

  Future<void> send(String collection, String document, data) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .set(data);
  }

  Future<void> deleteTalkRoom(String document) async {
    return await FirebaseFirestore.instance
        .collection(talkRoomDB)
        .doc(document)
        .delete();
  }

  Future<void> delete(String collection, String document) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .delete();
  }

  Future<QuerySnapshot> getSnapshotTalkRooms() async {
    return await getSnapshot(talkRoomDB);
  }

  Future<QuerySnapshot> getSnapshot(String collection) async {
    return await FirebaseFirestore.instance.collection(collection).get();
  }

  Stream<QuerySnapshot> streamSnapshots(String collection) {
    return FirebaseFirestore.instance.collection(collection).snapshots();
  }

  StreamSubscription<QuerySnapshot> onListenTalkRooms(
      void onData(QuerySnapshot event)) {
    return onListen(talkRoomDB, onData);
  }

  StreamSubscription<QuerySnapshot> onListen(
      String collection, void onData(QuerySnapshot event)) {
    var stream = streamSnapshots(collection);
    return stream.listen(onData);
  }

  Future<void> _createUserData() async {
    var self =
        await FirebaseFirestore.instance.collection(usersDB).doc(udid).get();

    var data = self.data() as Map;

    if (data == null) {
      gender = "その他";
      age = "18";
      searchGender = "なし";
      searchMinAge = "なし";
      searchMaxAge = "なし";

      await FirebaseFirestore.instance.collection(usersDB).doc(udid).set({
        'gender': gender,
        'age': age,
        'search_gender': searchGender,
        'search_age_min': searchMinAge,
        'search_age_max': searchMaxAge,
      });

      LocalDatabase().createUser();
    } else {
      gender = data["gender"];
      age = data["age"];
      searchGender = data["search_gender"];
      searchMinAge = data["search_age_min"];
      searchMaxAge = data["search_age_max"];
    }
  }

  Future<Map<String, dynamic>> getSelfUserData() async {
    var self =
        await FirebaseFirestore.instance.collection(usersDB).doc(udid).get();
    return self.data();
  }

  setSelfUserData(Map<String, dynamic> data) async {
    gender = data["gender"];
    age = data["age"];
    searchGender = data["search_gender"];
    searchMinAge = data["search_age_min"];
    searchMaxAge = data["search_age_max"];

    await FirebaseFirestore.instance.collection(usersDB).doc(udid).set({
      'gender': gender,
      'age': age,
      'search_gender': searchGender,
      'search_age_min': searchMinAge,
      'search_age_max': searchMaxAge,
    });
  }
}
