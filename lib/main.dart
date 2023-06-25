import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kids_development/levels/main_page.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'const.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes);
  MobileAds.instance
    ..updateRequestConfiguration(requestConfiguration)
    ..initialize();

  runZonedGuarded<Future<void>>(() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(MyApp());
    });
  }, (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<SharedPreferences> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = _getSharedPrefsAndInitCrashlytics();
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
          if (snapshot.hasData && snapshot.data != null) {
            return MainPage(snapshot.data!);
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

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors to Crashlytics.
    var originalOnError = FlutterError.onError;
    if (originalOnError != null) {
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        // Forward to original handler.
        originalOnError(errorDetails);
      };
    }
  }

  Future<String> _getCurrentLocale() async {
    try {
      var languages = await Devicelocale.preferredLanguages;
      String preferredLanguage = languages?[0]?.toString() ?? 'en';
      var languageCode = preferredLanguage[0] + preferredLanguage[1];
      return languageCode;
    } on PlatformException {
      return 'en';
    }
  }

  Future<SharedPreferences> _getSharedPrefsAndInitCrashlytics() async {
    await _initializeFlutterFire();
    final prefs = await SharedPreferences.getInstance();
    final chosenLanguage = prefs.getString(Constants.CHOSEN_LANGUAGE_KEY);
    final localeLanguage = await _getCurrentLocale();
    prefs.setString(Constants.LOCALE_LANGUAGE_KEY, localeLanguage);

    if (chosenLanguage == null) {
      prefs.setString(Constants.CHOSEN_LANGUAGE_KEY, localeLanguage);
    }

    return prefs;
  }
}
