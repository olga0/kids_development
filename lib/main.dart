import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:kids_development/levels/main_page.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

//  runZoned<Future<void>>(() async {
//    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
//    .then((_) {
//      runApp(MyApp());
//    });
//  }, onError: Crashlytics.instance.recordError);

  runZonedGuarded<Future<void>>(() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(MyApp());
    });
  }, (Object error, StackTrace stack) {
    Crashlytics.instance.recordError(error, stack);
  });
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = _getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: FutureBuilder<SharedPreferences>(
        future: _prefs,
        builder: (BuildContext context,
            AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            return MainPage(snapshot.data);
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text('Kids Development'),
                ),
                body: Center(child: CircularProgressIndicator())
            );
          }
        },
      ),
    );
  }

  Future<String> _getCurrentLocale() async {
    try {
      var languages = await Devicelocale.preferredLanguages;
      print('languages: $languages');
      var preferredLanguage = languages[0];
      print('preffered language: $preferredLanguage');
      var languageCode = preferredLanguage[0] + preferredLanguage[1];
      print('language code: $languageCode');
      return languageCode;
    } on PlatformException {
      print("Error obtaining current language");
      return 'en';
    }
  }

  Future<SharedPreferences> _getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String chosenLanguage = prefs.get(Constants.CHOSEN_LANGUAGE_KEY);
    String localeLanguage = await _getCurrentLocale();
    prefs.setString(Constants.LOCALE_LANGUAGE_KEY, localeLanguage);

    if (chosenLanguage == null) {
      prefs.setString(Constants.CHOSEN_LANGUAGE_KEY, localeLanguage);
    }

    return prefs;
  }
}
