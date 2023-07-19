import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kids_development/ads_manager.dart';
import 'package:kids_development/const.dart';
import 'package:kids_development/cubits/main/main_state.dart';
import 'package:kids_development/purchase_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit({
    required this.sharedPreferences,
    required this.purchaseManager,
    required this.adsManager,
  }) : super(const MainState.loading()) {
    _setUpRefreshStreamSubscription();
  }

  @visibleForTesting
  MainCubit.test({
    required MainState state,
    required this.sharedPreferences,
    required this.purchaseManager,
    required this.adsManager,
    bool setUpSubscriptions = true,
  }) : super(state) {
    // For some tests, need to skip this.
    if (setUpSubscriptions) {
      _setUpRefreshStreamSubscription();
    }
  }

  late SharedPreferences sharedPreferences;
  late PurchaseManager purchaseManager;
  late AdsManager adsManager;
  StreamSubscription<bool>? _purchaseManagerStreamSubscription;

  ProductDetails? get adsProduct => purchaseManager.getAdsProduct();

  void load() => state.mapOrNull(
        loading: (_) async {
          await purchaseManager.initializePurchaseData();
          adsManager.loadAds();
          return null;
        },
      );

  void buyProduct(ProductDetails product) => state.mapOrNull(
      loaded: (value) =>
          value.isAdRemoved ? null : purchaseManager.buyProduct(product));

  void showAd() => state.mapOrNull(
      loaded: (value) => value.isAdRemoved ? null : adsManager.showAds());

  void setLanguage(String language) => state.mapOrNull(
      loaded: (value) => emit(MainState.loaded(
          isAdRemoved: value.isAdRemoved,
          chosenLanguage: language,
          localeLanguage: value.localeLanguage)));

  @override
  Future<void> close() async {
    await _purchaseManagerStreamSubscription?.cancel();
    return super.close();
  }

  void _setUpRefreshStreamSubscription() {
    _purchaseManagerStreamSubscription =
        purchaseManager.purchaseStateStream.listen((isAdRemoved) {
      emit(MainState.loaded(
          isAdRemoved: isAdRemoved,
          chosenLanguage:
              sharedPreferences.getString(Constants.CHOSEN_LANGUAGE_KEY) ?? '',
          localeLanguage:
              sharedPreferences.getString(Constants.LOCALE_LANGUAGE_KEY) ??
                  ''));
    });
  }
}
