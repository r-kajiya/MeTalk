import 'package:flutter/material.dart';
import 'package:talk/page/hello_page.dart';
import 'package:talk/page/home_page.dart';
import 'package:talk/page/calling_page.dart';
import 'package:talk/page/talk_page.dart';
import 'package:talk/page/profile_page.dart';
import 'package:talk/page/search_page.dart';
import 'package:talk/page/standby_page.dart';
import 'package:talk/database/database.dart';
import 'util/ads.dart';
import '../database/local_database.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await AppTrackingTransparency.requestTrackingAuthorization();
  print('ATT Status = $status');
  Ads().setup();
  await Database().setup();
  await LocalDatabase().setup();
  runApp(Center(child: LifecycleWatcher()));
}

class LifecycleWatcher extends StatefulWidget {
  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print(state);
        Database().deleteTalkRoom(Database().udid);
        break;
      case AppLifecycleState.paused:
        print(state);
        Database().deleteTalkRoom(Database().udid);
        break;
      case AppLifecycleState.resumed:
        print(state);
        Database().deleteTalkRoom(Database().udid);
        break;
      case AppLifecycleState.detached:
        print(state);
        Database().deleteTalkRoom(Database().udid);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Hontana',
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => HelloPage(),
        '/home': (BuildContext context) => HomePage(),
        '/calling': (BuildContext context) => CallingPage(),
        '/talk': (BuildContext context) => TalkPage(),
        '/profile': (BuildContext context) => ProfilePage(),
        '/search': (BuildContext context) => SearchPage(),
        '/standby': (BuildContext context) => StandbyPage(),
      },
    );
  }
}
