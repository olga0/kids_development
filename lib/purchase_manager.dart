import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'const.dart';

class PurchaseManager {
  final Function _setMainPageState;
  final SharedPreferences _prefs;

  PurchaseManager(this._setMainPageState, this._prefs);

  // The In App Purchase plugin
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Updates to purchases
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product ID
  Set<String> _idSet = <String>[Constants.PRODUCT_ID].toSet();

  // Products for sale
  List<ProductDetails> _products = [];

  Future<bool> initializePurchaseData() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _updateUIIfBillingNotAvailable();
    });
    await _initStoreInfo();
    return true;
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();

    if (!isAvailable) {
      _updateUIIfBillingNotAvailable();
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_idSet);

    if (productDetailResponse.error != null) {
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _updateUIIfBillingNotAvailable();
      return;
    }

    _products = productDetailResponse.productDetails;

    await _inAppPurchase.restorePurchases();
  }

  // Returns ads purchase
  PurchaseDetails? _getAdsPurchase(List<PurchaseDetails> purchaseDetailsList) {
    return purchaseDetailsList.firstWhereOrNull(
        (purchase) => _getPurchaseProductId(purchase) == Constants.PRODUCT_ID);
  }

  // Returns ads product
  ProductDetails? getAdsProduct() {
    return _products
        .firstWhereOrNull((product) => product.id == Constants.PRODUCT_ID);
  }

  String _getPurchaseProductId(PurchaseDetails purchase) {
    if (Platform.isAndroid) {
      var purchaseDataDecoded =
          jsonDecode(purchase.verificationData.localVerificationData);
      String purchaseProductId = purchaseDataDecoded["productId"];
      return purchaseProductId;
    } else {
      return purchase.productID;
    }
  }

  // Setup a consumable
  void _verifyPurchase(PurchaseDetails purchaseDetails) {
    // platform is Android
    String purchaseData =
        purchaseDetails.verificationData.localVerificationData;
    var purchaseDataDecoded = jsonDecode(purchaseData);
    if (purchaseDataDecoded.containsKey("purchaseState") &&
        (purchaseDataDecoded["purchaseState"] == 0)) {
      // purchased
      _setMainPageState(isAdsRemoved: true);
      _prefs.setBool(Constants.IS_AD_REMOVED_KEY, true);
    } else {
      // not purchased
      _setMainPageState(isAdsRemoved: false);
      _prefs.setBool(Constants.IS_AD_REMOVED_KEY, false);
    }
  }

  /// Purchase a product
  void buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    PurchaseDetails? purchaseDetails = _getAdsPurchase(purchaseDetailsList);
    if (purchaseDetails != null) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // TODO show purchase error snack bar
        _updateUIIfBillingNotAvailable();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // TODO show purchase error snack bar
          _updateUIIfBillingNotAvailable();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyPurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void cancelSubscription() {
    _subscription.cancel();
  }

  void _updateUIIfBillingNotAvailable() {
    _products = [];

    bool? isAdRemovedPref = _prefs.getBool(Constants.IS_AD_REMOVED_KEY);

    if (isAdRemovedPref == null || isAdRemovedPref == false) {
      _setMainPageState(isAdsRemoved: false);
    } else {
      _setMainPageState(isAdsRemoved: true);
    }
  }
}
