import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kids_development/ads_manager.dart';
import 'package:kids_development/level_button.dart';
import 'package:kids_development/levels/edible_or_not.dart';
import 'package:kids_development/levels/matching_items_page.dart';
import 'package:kids_development/levels/occupations_and_vehicles_page.dart';
import 'package:kids_development/levels/odd_one_out_page.dart';
import 'package:kids_development/levels/wild_or_farm_page.dart';
import 'package:kids_development/my_localizations.dart';
import 'package:kids_development/purchase_manager.dart';
import 'package:kids_development/string_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';

class MainPage extends StatefulWidget {
  final SharedPreferences _prefs;

  MainPage(this._prefs);

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  late String _chosenLanguage;
  late String _localeLanguage;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // variables for ad
  late AdsManager _adsManager;

  // variables for in-app purchases
  bool _isAdRemoved = false;
  late PurchaseManager _purchaseManager;
  late Future<bool> _isPurchaseDataInitializationFinished;

  @override
  void initState() {
    _purchaseManager = new PurchaseManager(_setMainPageState, widget._prefs);
    _adsManager = new AdsManager();

    _chosenLanguage =
        widget._prefs.getString(Constants.CHOSEN_LANGUAGE_KEY) ?? '';
    _localeLanguage =
        widget._prefs.getString(Constants.LOCALE_LANGUAGE_KEY) ?? '';
    _isPurchaseDataInitializationFinished =
        _purchaseManager.initializePurchaseData();
    _adsManager.loadAds();

    super.initState();
  }

  @override
  void dispose() {
    _adsManager.disposeAds();
    _purchaseManager.cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _isPurchaseDataInitializationFinished,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            // task is finished
            print('snapshot has data');
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Kids Development'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.language),
                    onPressed: () {
                      _showLanguageDialog(context);
                    },
                  )
                ],
              ),
              body: Container(
                width: double.infinity,
                margin: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    LevelButton(
                            context: context,
                            label: MyLocalizations.of(
                                _chosenLanguage, StringKeys.oddOneOut),
                            route: MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OddOneOutPage(_chosenLanguage, _showAd)),
                            icon: 'images/odd_one_out_icon.png',
                            borderColor: Colors.green,
                            backgroundColor: (Colors.green[100])!,
                            highlightColor: (Colors.green[200])!,
                            textColor: (Colors.green[700])!)
                        .draw(),
                    SizedBox(width: 20, height: 20),
                    LevelButton(
                            context: context,
                            label: MyLocalizations.of(_chosenLanguage,
                                StringKeys.occupationsAndVehicles),
                            route: MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OccupationsAndVehiclesPage(
                                        _chosenLanguage, _showAd)),
                            icon: 'images/who_rides_what_icon.png',
                            borderColor: Colors.amber,
                            backgroundColor: (Colors.amber[50])!,
                            highlightColor: (Colors.amber[200])!,
                            textColor: (Colors.amber[700])!)
                        .draw(),
                    SizedBox(width: 20, height: 20),
                    LevelButton(
                            context: context,
                            label: MyLocalizations.of(
                                _chosenLanguage, StringKeys.wildOrFarm),
                            route: MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WildOrFarmPage(_chosenLanguage, _showAd)),
                            icon: 'images/pig.png',
                            borderColor: Colors.pink,
                            backgroundColor: (Colors.pink[50])!,
                            highlightColor: (Colors.pink[200])!,
                            textColor: (Colors.pink[700])!)
                        .draw(),
                    SizedBox(width: 20, height: 20),
                    LevelButton(
                            context: context,
                            label: MyLocalizations.of(
                                _chosenLanguage, StringKeys.edibleOrNotEdible),
                            route: MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EdibleOrNotPage(_chosenLanguage, _showAd)),
                            icon: 'images/edible_or_not_icon.png',
                            borderColor: Colors.blue,
                            backgroundColor: (Colors.blue[100])!,
                            highlightColor: (Colors.blue[200])!,
                            textColor: (Colors.blue[700])!)
                        .draw(),
                    SizedBox(width: 20, height: 20),
                    LevelButton(
                            context: context,
                            label: MyLocalizations.of(
                                _chosenLanguage, StringKeys.matchingItems),
                            route: MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    MatchingItemsPage(
                                        _chosenLanguage, _showAd)),
                            icon: 'images/matching_icon.png',
                            borderColor: Colors.red,
                            backgroundColor: (Colors.red[100])!,
                            highlightColor: (Colors.red[200])!,
                            textColor: (Colors.red[700])!)
                        .draw(),
                    SizedBox(width: 20, height: 20),
                    _buildRemoveAdsButton(),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text('Kids Development'),
                ),
                body: Center(child: CircularProgressIndicator()));
          }
        });
  }

  Widget _buildRemoveAdsButton() {
    // check if remove ads product was retrieved
    print('isAdRemoved = $_isAdRemoved');
    ProductDetails? prod = _purchaseManager.getAdsProduct();
    if (prod == null) {
      print('Product was not found');
      return Container();
    } else {
      if (_isAdRemoved) {
        // UI if purchased
        return Container();
      }
      // UI if NOT purchased
      else {
        return ElevatedButton(
          onPressed: () {
            var context = _scaffoldKey.currentContext;
            if (context != null) {
              _showPurchaseDialog(context, prod);
            }
          },
          child: Text(
              MyLocalizations.of(_localeLanguage, StringKeys.marketDialogTitle),
              style: TextStyle(fontSize: 20, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.purple)),
            backgroundColor: Colors.purple,
          ),
        );
      }
    }
  }

  void _showAd() {
    if (!_isAdRemoved) {
      _adsManager.showAds();
    }
  }

  void _showLanguageDialog(BuildContext context) {
    SimpleDialog dialog = SimpleDialog(
      title: Text(
          MyLocalizations.of(_localeLanguage, StringKeys.languageDialogTitle)),
      children: <Widget>[
        SimpleDialogOption(
          child: Text(MyLocalizations.of(
              _localeLanguage, StringKeys.languageDialogOption1)),
          onPressed: () {
            setState(() {
              _chosenLanguage = 'en';
              widget._prefs
                  .setString(Constants.CHOSEN_LANGUAGE_KEY, _chosenLanguage);
              Navigator.of(context).pop();
            });
          },
        ),
        SimpleDialogOption(
          child: Text(MyLocalizations.of(
              _localeLanguage, StringKeys.languageDialogOption2)),
          onPressed: () {
            setState(() {
              _chosenLanguage = 'ru';
              widget._prefs
                  .setString(Constants.CHOSEN_LANGUAGE_KEY, _chosenLanguage);
              Navigator.of(context).pop();
            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void _showPurchaseDialog(BuildContext context, ProductDetails prod) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(
        MyLocalizations.of(_localeLanguage, StringKeys.marketDialogText));
    buffer.write(prod.price);
    buffer.write('?');
    String text = buffer.toString();

    AlertDialog dialog = AlertDialog(
      title: Text(
          MyLocalizations.of(_localeLanguage, StringKeys.marketDialogTitle)),
      content: Text(text),
      actions: <Widget>[
        TextButton(
            child: Text(
              MyLocalizations.of(
                  _localeLanguage, StringKeys.marketDialogNegButLabel),
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        TextButton(
            child: Text(
              MyLocalizations.of(
                  _localeLanguage, StringKeys.marketDialogPosButLabel),
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              _purchaseManager.buyProduct(prod);
              Navigator.of(context).pop();
            }),
      ],
    );

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void _setMainPageState({@required bool? isAdsRemoved}) {
    if (isAdsRemoved != null) {
      setState(() {
        _isAdRemoved = isAdsRemoved;
      });
    }
  }
}
