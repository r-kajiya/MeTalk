import 'package:flutter/material.dart';
import 'package:talk/database/database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _searchGender;
  String _selectedMinAge;
  String _selectedMaxAge;

  @override
  void initState() {
    Function(Map<String, dynamic>) success = (data) {
      _searchGender = data["search_gender"];
      _selectedMinAge = data["search_age_min"];
      _selectedMaxAge = data["search_age_max"];
      _initGender(data["gender"]);
      _initAge(data["age"]);
    };

    Database().getSelfUserData().then((data) => {success(data)});

    _ageList.clear();

    for (int i = 18; i < 60; i++) {
      _ageList.add(i.toString());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text('Profile'),
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

  final List<String> _genderList = [
    "男",
    "女",
    "その他",
  ];
  String _selectedGender = "男";

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
        onChanged: _onChangedGender,
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

  void _onChangedGender(String selected) {
    setState(() {
      _selectedGender = selected;
    });
  }

  List<String> _ageList = [];
  String _selectedAge = "18";

  _initAge(String age) {
    setState(() {
      _selectedAge = age;
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
          value: _selectedAge.toString(),
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 40,
          elevation: 16,
          underline: Container(
            height: 1,
            color: Colors.grey,
          ),
          onChanged: _onChangedAge,
          items: _ageList.map((String age) {
            return DropdownMenuItem(
              value: age,
              child: Text(
                age,
                style: TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  void _onChangedAge(String selected) {
    setState(() {
      _selectedAge = selected;
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
      'gender': _selectedGender,
      'age': _selectedAge,
      'search_gender': _searchGender,
      'search_age_min': _selectedMinAge,
      'search_age_max': _selectedMaxAge,
    });

    setState(() {
      Navigator.of(context).pushNamed('/home');
    });
  }
}
