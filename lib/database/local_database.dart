import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:core';

class TimeSet {
  int unixSecond;
  int index;

  TimeSet(int unixSecond, int index) {
    this.unixSecond = unixSecond;
    this.index = index;
  }
}

class LocalDatabase {
  static LocalDatabase _instance;

  LocalDatabase._();

  factory LocalDatabase() {
    if (_instance == null) {
      _instance = new LocalDatabase._();
    }
    return _instance;
  }

  List<int> remainingTimeList = [0, 0, 0, 0];
  final int remainingTime = 1000;
  bool isTermsOfService;

  setup() async {
    for (int i = 0; i < remainingTimeList.length; i++) {
      getStamina(i).then(_setupStamina);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    isTermsOfService = prefs.getBool("terms_of_service");
    if (isTermsOfService == null) {
      isTermsOfService = false;
    }
  }

  secondUpdate() {
    for (int i = 0; i < remainingTimeList.length; i++) {
      if (remainingTimeList[i] > 0) {
        remainingTimeList[i]--;
      }
    }
  }

  recoverStamina(int index) {
    remainingTimeList[index] = 0;
    setStamina(index, 0);
  }

  depletesStamina() {
    int index = -1;
    for (int i = 0; i < remainingTimeList.length; i++) {
      if (remainingTimeList[i] == 0) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      return;
    }

    remainingTimeList[index] = 1000;
    int seconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    setStamina(index, seconds);
  }

  _setupStamina(TimeSet timeSet) {
    int seconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int remaining = remainingTime - (seconds - timeSet.unixSecond);
    if (remaining <= 0) {
      remaining = 0;
    }
    remainingTimeList[timeSet.index] = remaining;
  }

  createUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 4; i++) {
      prefs.setInt("stamina_used_time" + i.toString(), 0);
    }
  }

  Future<TimeSet> getStamina(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int unixSecond = prefs.getInt("stamina_used_time" + index.toString());
    if (unixSecond == null) {
      unixSecond = 0;
    }
    return TimeSet(unixSecond, index);
  }

  setStamina(int index, int unixSecond) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("stamina_used_time" + index.toString(), unixSecond);
  }

  applyTermsOfService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("terms_of_service", true);
  }

  bool canCall() {
    for (int i = 0; i < remainingTimeList.length; i++) {
      if (remainingTimeList[i] == 0) {
        return true;
      }
    }
    return false;
  }
}
