import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'const.dart';


class AdsManager {
  InterstitialAd? _interstitialAd;
  int _counter = 0;
  int _attemptsToLoad = 0;
  bool _isAdLoaded = false;

  static const AdRequest request =
  AdRequest(keywords: ['Games', 'Puzzles', 'Kids']);

  void loadAds() async {
    if (!_isAdLoaded) {
      return InterstitialAd.load(
          adUnitId: Constants.UNIT_ID,
          request: request,
          adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: onAdLoaded,
              onAdFailedToLoad: (error) {
                _attemptsToLoad += 1;
                _interstitialAd = null;
                if (_attemptsToLoad < 2) {
                  loadAds();
                }
              }));
    }
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _attemptsToLoad = 0;
    _interstitialAd?.setImmersiveMode(true);
    _isAdLoaded = true;
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _isAdLoaded = false;
        loadAds();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _isAdLoaded = false;
        loadAds();
      },
      onAdClicked: (InterstitialAd ad) {
        ad.dispose();
        _isAdLoaded = false;
        loadAds();
      },
    );
  }

  void disposeAds() {
    _interstitialAd?.dispose();
  }

  Future<void> showAds() async {
    if (_interstitialAd != null && _isAdLoaded) {
      _counter++;
      if (_counter > 1) {
        _interstitialAd!.show();
        _interstitialAd = null;
      }
    } else {
      loadAds();
    }
  }
}