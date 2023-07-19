import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kids_development/ads_manager.dart';
import 'package:kids_development/cubits/main/main_cubit.dart';
import 'package:kids_development/levels/main_page.dart';
import 'package:flutter/services.dart';
import 'package:kids_development/purchase_manager.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes);
  MobileAds.instance
    ..updateRequestConfiguration(requestConfiguration)
    ..initialize();

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

  // Get current locale.
  String currentLocale;
  try {
    final languages = await Devicelocale.preferredLanguages;
    String preferredLanguage = languages?[0]?.toString() ?? 'en';
    currentLocale = preferredLanguage[0] + preferredLanguage[1];
  } on PlatformException {
    currentLocale = 'en';
  }

  final prefs = await SharedPreferences.getInstance();
  final chosenLanguage = prefs.getString(Constants.CHOSEN_LANGUAGE_KEY);
  final localeLanguage = currentLocale;
  prefs.setString(Constants.LOCALE_LANGUAGE_KEY, localeLanguage);

  if (chosenLanguage == null) {
    prefs.setString(Constants.CHOSEN_LANGUAGE_KEY, localeLanguage);
  }

  final purchaseManager = PurchaseManager(prefs);
  final adsManager = AdsManager();
  final mainCubit = MainCubit(
      sharedPreferences: prefs,
      purchaseManager: purchaseManager,
      adsManager: adsManager);
  mainCubit.load();

  runZonedGuarded<Future<void>>(() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(App(
        blocProviders: [
          BlocProvider<MainCubit>.value(value: mainCubit),
        ],
        providers: [
          Provider<PurchaseManager>.value(value: purchaseManager),
          Provider<SharedPreferences>.value(value: prefs),
          Provider<AdsManager>.value(value: adsManager),
        ],
      ));
    });
  }, (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.providers,
    required this.blocProviders,
  }) : super(key: key);

  final List<BlocProvider> blocProviders;

  final List<SingleChildWidget> providers;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
      providers: blocProviders,
      child: MultiProvider(
        providers: providers,
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.amber,
          ),
          home: MainPage(),
        ),
      ));
}
