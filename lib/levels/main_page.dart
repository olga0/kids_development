import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kids_development/ads_manager.dart';
import 'package:kids_development/cubits/main/main-cubit.dart';
import 'package:kids_development/cubits/main/main_state.dart';
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

class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) => BlocProvider<MainCubit>(
        create: _create,
        child: BlocBuilder<MainCubit, MainState>(
          builder: (context, state) {
            final cubit = context.read<MainCubit>();
            return state.map(
              loading: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text('Kids Development'),
                  ),
                  body: Center(child: CircularProgressIndicator())),
              loaded: (value) => Scaffold(
                    appBar: AppBar(
                      title: Text('Kids Development'),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.language),
                          onPressed: () {
                            _showLanguageDialog(
                              context: context,
                              cubit: cubit,
                              localeLanguage: value.localeLanguage,
                              prefs: cubit.sharedPreferences,
                            );
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
                                      value.chosenLanguage,
                                      StringKeys.oddOneOut),
                                  route: MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          OddOneOutPage(
                                              value.chosenLanguage, cubit.showAd)),
                                  icon: 'images/odd_one_out_icon.png',
                                  borderColor: Colors.green,
                                  backgroundColor: (Colors.green[100])!,
                                  highlightColor: (Colors.green[200])!,
                                  textColor: (Colors.green[700])!)
                              .draw(),
                          SizedBox(width: 20, height: 20),
                          LevelButton(
                                  context: context,
                                  label: MyLocalizations.of(
                                      value.chosenLanguage,
                                      StringKeys.occupationsAndVehicles),
                                  route: MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          OccupationsAndVehiclesPage(
                                              value.chosenLanguage, cubit.showAd)),
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
                                      value.chosenLanguage,
                                      StringKeys.wildOrFarm),
                                  route: MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          WildOrFarmPage(
                                              value.chosenLanguage, cubit.showAd)),
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
                                      value.chosenLanguage,
                                      StringKeys.edibleOrNotEdible),
                                  route: MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EdibleOrNotPage(
                                              value.chosenLanguage, cubit.showAd)),
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
                                      value.chosenLanguage,
                                      StringKeys.matchingItems),
                                  route: MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          MatchingItemsPage(
                                              value.chosenLanguage, cubit.showAd)),
                                  icon: 'images/matching_icon.png',
                                  borderColor: Colors.red,
                                  backgroundColor: (Colors.red[100])!,
                                  highlightColor: (Colors.red[200])!,
                                  textColor: (Colors.red[700])!)
                              .draw(),
                          if (cubit.adsProduct != null && !value.isAdRemoved) ...[
                            SizedBox(width: 20, height: 20),
                            _RemoveAdsButton(
                              parentContext: context,
                              adsProduct: cubit.adsProduct!,
                              localeLanguage: value.localeLanguage,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ));
          },
        ),
      );

  void _showLanguageDialog({
    required BuildContext context,
    required String localeLanguage,
    required SharedPreferences prefs,
    required MainCubit cubit,
  }) {
    SimpleDialog dialog = SimpleDialog(
      title: Text(
          MyLocalizations.of(localeLanguage, StringKeys.languageDialogTitle)),
      children: <Widget>[
        SimpleDialogOption(
          child: Text(MyLocalizations.of(
              localeLanguage, StringKeys.languageDialogOption1)),
          onPressed: () {
            cubit.setLanguage('en');
            prefs.setString(Constants.CHOSEN_LANGUAGE_KEY, 'en');
            Navigator.of(context).pop();
          },
        ),
        SimpleDialogOption(
          child: Text(MyLocalizations.of(
              localeLanguage, StringKeys.languageDialogOption2)),
          onPressed: () {
            cubit.setLanguage('ru');
            prefs.setString(Constants.CHOSEN_LANGUAGE_KEY, 'ru');
            Navigator.of(context).pop();
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

  MainCubit _create(BuildContext context) {
    try {
      return context.read<MainCubit>();
    } on ProviderNotFoundException catch (_) {
      return MainCubit(
          sharedPreferences: context.read<SharedPreferences>(),
          purchaseManager: context.read<PurchaseManager>(),
          adsManager: context.read<AdsManager>())
        ..load();
    }
  }
}

class _RemoveAdsButton extends StatelessWidget {
  _RemoveAdsButton({
    Key? key,
    required ProductDetails adsProduct,
    required BuildContext parentContext,
    required String localeLanguage,
  }) : super(key: key);

  late final ProductDetails adsProduct;
  late final BuildContext parentContext;
  late final String localeLanguage;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => _showPurchaseDialog(parentContext, adsProduct, localeLanguage),
        child: Text(
            MyLocalizations.of(localeLanguage, StringKeys.marketDialogTitle),
            style: TextStyle(fontSize: 20, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Colors.purple)),
          backgroundColor: Colors.purple,
        ),
      );

  void _showPurchaseDialog(
    BuildContext context,
    ProductDetails prod,
    String localeLanguage,
  ) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(
        MyLocalizations.of(localeLanguage, StringKeys.marketDialogText));
    buffer.write(prod.price);
    buffer.write('?');
    String text = buffer.toString();

    AlertDialog dialog = AlertDialog(
      title: Text(
          MyLocalizations.of(localeLanguage, StringKeys.marketDialogTitle)),
      content: Text(text),
      actions: <Widget>[
        TextButton(
            child: Text(
              MyLocalizations.of(
                  localeLanguage, StringKeys.marketDialogNegButLabel),
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        TextButton(
            child: Text(
              MyLocalizations.of(
                  localeLanguage, StringKeys.marketDialogPosButLabel),
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              context.read<MainCubit>().buyProduct(prod);
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
}
