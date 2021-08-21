import 'package:flutter/material.dart';
import 'package:talk/database/database.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _genderUser;
  String _ageUser;

  @override
  void initState() {
    Function(Map<String, dynamic>) success = (data) {
      _genderUser = data["gender"];
      _ageUser = data["age"].toString();

      _initGender(data["search_gender"]);
      _initAge(data["search_age_min"], data["search_age_max"]);
    };

    Database().getSelfUserData().then((data) => {success(data)});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text('Search'),
        ),
        backgroundColor: Colors.pink,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _gender(),
              _age(),
              _save(),
            ]));
  }

  final List<String> _genderList = ["なし", "男", "女", "その他"];
  String _selectedGender = "なし";

  _initGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  Row _gender() {
    return Row(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(5.0),
      ),
      Text("性別："),
      DropdownButton(
        value: _selectedGender,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 40,
        elevation: 16,
        underline: Container(
          height: 1,
          color: Colors.grey,
        ),
        onChanged: _onChangedSex,
        items: _genderList.map((String itemString) {
          return DropdownMenuItem(
            value: itemString,
            child: Text(
              itemString,
              style: TextStyle(color: Colors.black, fontSize: 15.0),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  void _onChangedSex(String selected) {
    setState(() {
      _selectedGender = selected;
    });
  }

  List<String> _minAgeList = [];
  List<String> _maxAgeList = [];
  String _selectedMinAge = "なし";
  String _selectedMaxAge = "なし";

  _initAge(String minAge, String maxAge) {
    _minAgeList.clear();
    _maxAgeList.clear();

    _minAgeList.add("なし");
    _maxAgeList.add("なし");

    for (int i = 18; i < 60; i++) {
      _minAgeList.add(i.toString());
      _maxAgeList.add(i.toString());
    }

    setState(() {
      _selectedMinAge = minAge;
      _selectedMaxAge = maxAge;
    });
  }

  Row _age() {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(5.0),
        ),
        Text("年齢："),
        DropdownButton(
          value: _selectedMinAge,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 40,
          elevation: 16,
          underline: Container(
            height: 1,
            color: Colors.grey,
          ),
          onChanged: _onChangedMinAge,
          items: _minAgeList.map((String age) {
            return DropdownMenuItem(
              value: age,
              child: Text(
                age,
                style: TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            );
          }).toList(),
        ),
        Text("〜 "),
        DropdownButton(
          value: _selectedMaxAge,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 40,
          elevation: 16,
          underline: Container(
            height: 1,
            color: Colors.grey,
          ),
          onChanged: _onChangedMaxAge,
          items: _maxAgeList.map((String age) {
            return DropdownMenuItem(
              value: age,
              child: Text(
                age,
                style: TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onChangedMinAge(String selected) {
    if (selected != "なし") {
      if (_selectedMaxAge != "なし") {
        int maxAge = int.parse(_selectedMaxAge);
        int minAge = int.parse(selected);
        if (maxAge <= minAge) {
          selected = maxAge.toString();
        }
      }
    }

    setState(() {
      _selectedMinAge = selected;
    });
  }

  void _onChangedMaxAge(String selected) {
    if (selected != "なし") {
      if (_selectedMinAge != "なし") {
        int maxAge = int.parse(selected);
        int minAge = int.parse(_selectedMinAge);
        if (minAge >= maxAge) {
          selected = minAge.toString();
        }
      }
    }

    setState(() {
      _selectedMaxAge = selected;
    });
  }

  Padding _save() {
    return Padding(
      padding: EdgeInsets.all(60.0),
      child: ElevatedButton(
        child: const Text('Save'),
        style: ElevatedButton.styleFrom(
          primary: Colors.pinkAccent,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _onPressedSave();
        },
      ),
    );
  }

  void _onPressedSave() {
    Database().setSelfUserData({
      'gender': _genderUser,
      'age': _ageUser,
      'search_gender': _selectedGender,
      'search_age_min': _selectedMinAge,
      'search_age_max': _selectedMaxAge,
    });

    setState(() {
      Navigator.of(context).pushNamed('/home');
    });
  }
}
