import 'package:firebase_admob/firebase_admob.dart';

import 'const.dart';


class AdsManager {
  InterstitialAd _interstitialAd;
  int _counter = 0;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      testDevices: ['XT1526'],
      childDirected: true,
      keywords: ['Games', 'Puzzles', 'Kids']);

  InterstitialAd _buildInterstitial() {
    return InterstitialAd(
      adUnitId: Constants.UNIT_ID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
        if (event == MobileAdEvent.failedToLoad) {
          print('Trying to reload add');
          _interstitialAd.load();
        } else if (event == MobileAdEvent.closed) {
          _interstitialAd = _buildInterstitial()..load();
        }
      },
    );
  }

  void initAds() {
    if (_interstitialAd == null) _interstitialAd = _buildInterstitial();
  }

  void disposeAds() {
    _interstitialAd?.dispose();
  }

  Future<void> showAds() async {
    if (_interstitialAd != null) {
      _counter++;
      bool result = await _interstitialAd.load();

      if (result && _counter > 1) {
        _interstitialAd.show();
      }
//        ..load()
//        ..show();
    }
  }
}