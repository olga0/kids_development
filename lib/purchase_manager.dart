import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class PurchaseManager {
  final Function _setMainPageState;
  final SharedPreferences _prefs;

  PurchaseManager(this._setMainPageState, this._prefs);

  // The In App Purchase plugin
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  // Updates to purchases
  StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product ID
  Set<String> _idSet = <String>[Constants.PRODUCT_ID].toSet();

  // Products for sale
  List<ProductDetails> _products = [];

  // Past purchases
  List<PurchaseDetails> _purchases = [];

  // Is the API available on the device
  bool _isAvailable = false;

  Future<bool> initializePurchaseData() async {
    // Check availability of In App Purchases
    _isAvailable = await _connection.isAvailable();
    print('isAvailable = $_isAvailable');

    if (_isAvailable) {
      // In App Purchases available
      await _getProducts();
      await _getPastPurchases();

      // Verify and deliver a purchase
      _verifyPurchase();

      // Listen to new purchases
      _subscription = _connection.purchaseUpdatedStream.listen((data) {
        print('NEW PURCHASE');
        _purchases.addAll(data);
        _verifyPurchase();
        _getPastPurchases();
      });
    } else {
      bool isAdRemovedPref = _prefs.getBool(Constants.IS_AD_REMOVED_KEY);

      if (isAdRemovedPref == null || isAdRemovedPref == false) {
        _setMainPageState(isAdsRemoved: false);
      } else {
        _setMainPageState(isAdsRemoved: true);
      }
    }
    return true;
  }

  // Get all products available for sale
  Future<void> _getProducts() async {
    ProductDetailsResponse response =
        await _connection.queryProductDetails(_idSet);
    _products = response.productDetails;
    print('PRODUCTS:');
    _products.forEach((product) {print('product title: "${product.title}", product id: ${product.id}');});
  }

  // Gets past purchases
  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response =
        await _connection.queryPastPurchases();

    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }
    print('purchase response is: $response');
    print('purchase response pastPurchases: ${response.pastPurchases}');
    print('purchase response error: ${response.error}');
    if (response.error != null) print ('error message: ${response.error.message}');
    _purchases = response.pastPurchases;

    if (response.pastPurchases == null) {
      print('response.pastPurchases = NULL');
    } else {
      print('purchase response pastPurchases length: ${response.pastPurchases.length}');
    }

    if (Platform.isAndroid) {
      print('PURCHASES:');
      _purchases.forEach((purchase) {
        print(
            'purchase id: ${purchase.status}, purchase status: ${purchase
                .status}');
        var purchaseData = purchase.verificationData.localVerificationData;
        var purchaseDataDecoded = jsonDecode(
            purchase.verificationData.localVerificationData);
        print('purchase data: $purchaseData');
        var purchaseId = purchaseDataDecoded["orderId"];
        var purchaseProductId = purchaseDataDecoded["productId"];
        var purchaseStatus = purchaseDataDecoded["purchaseState"];
        print('purchaseId: $purchaseId, purchaseProductId: $purchaseProductId, purchaseStatus: $purchaseStatus');
      });
    }
  }

  // Returns ads purchase
  PurchaseDetails getAdsPurchase() {
    return _purchases.firstWhere((purchase) => _getPurchaseProductId(purchase) == Constants.PRODUCT_ID,
        orElse: () => null);
  }

  // Returns ads product
  ProductDetails getAdsProduct() {
    return _products.firstWhere((product) => product.id == Constants.PRODUCT_ID,
        orElse: () => null);
  }

  String _getPurchaseProductId(PurchaseDetails purchase) {
    if (Platform.isAndroid) {
      var purchaseDataDecoded = jsonDecode(
          purchase.verificationData.localVerificationData);
      String purchaseProductId = purchaseDataDecoded["productId"];
      return purchaseProductId;
    } else {
      return purchase.productID;
    }
  }

  // Setup a consumable
  void _verifyPurchase() {

    if (_purchases == null || _purchases.length == 0) {
      // not purchased
      _setMainPageState(isAdsRemoved: false);
      _prefs.setBool(Constants.IS_AD_REMOVED_KEY, false);
    } else {
      // check if purchased
      PurchaseDetails purchase = getAdsPurchase();

      if (Platform.isAndroid) {
        // platform is Android
        var purchaseData = purchase.verificationData.localVerificationData;
        print('purchase data: $purchaseData');
        var purchaseDataDecoded = jsonDecode(purchaseData);
        if (purchaseDataDecoded.containsKey("purchaseState") &&
            (purchaseDataDecoded["purchaseState"] == 0)) {
          // purchased
          print('purchased');
          _setMainPageState(isAdsRemoved: true);
          _prefs.setBool(Constants.IS_AD_REMOVED_KEY, true);
        } else {
          // not purchased
          print('not purchased');
          _setMainPageState(isAdsRemoved: false);
          _prefs.setBool(Constants.IS_AD_REMOVED_KEY, false);
        }
      } else {
        // platform is not Android
        if (purchase != null && purchase.status == PurchaseStatus.purchased) {
          _setMainPageState(isAdsRemoved: true);
          _prefs.setBool(Constants.IS_AD_REMOVED_KEY, true);
        } else {
          _setMainPageState(isAdsRemoved: false);
          _prefs.setBool(Constants.IS_AD_REMOVED_KEY, false);
        }
      }
    }
  }

  /// Purchase a product
  void buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
     _connection.buyNonConsumable(purchaseParam: purchaseParam);
//    _connection.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  /// Consume purchase
  void consume(PurchaseDetails purchase) async {
    // Bring ads back
    _setMainPageState(isAdsRemoved: false);
    _prefs.setBool(Constants.IS_AD_REMOVED_KEY, false);

    // Mark purchase consumed
    BillingResponse res = await _connection.consumePurchase(purchase);
    print('Result of consuming is $res');
    await _getPastPurchases();
  }

  void cancelSubscription() {
    _subscription.cancel();
  }
}
