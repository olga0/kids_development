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

  // Past purchases
  List<PurchaseDetails> _purchases = [];

  // Is the API available on the device
  bool _isAvailable = false;

  bool _purchasePending = false;
  String? _queryProductError;

  Future<bool> initializePurchaseData() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // TODO handle error here.
      _updateUIIfBillingNotAvailable();
    });
    await _initStoreInfo();
    return true;
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    print('isAvailable = $_isAvailable');

    if (!isAvailable) {
      _isAvailable = isAvailable;
      _updateUIIfBillingNotAvailable();
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_idSet);

    if (productDetailResponse.error != null) {
      _queryProductError = productDetailResponse.error!.message;
      _isAvailable = isAvailable;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _queryProductError = null;
      _isAvailable = isAvailable;
      _updateUIIfBillingNotAvailable();
      return;
    }

    _products = productDetailResponse.productDetails;
    print('PRODUCTS:');
    _products.forEach((product) {
      print('product title: "${product.title}", product id: ${product.id}');
    });

    await _inAppPurchase.restorePurchases();
  }

  // Get all products available for sale
  Future<void> _getProducts() async {
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_idSet);

  }

  // Gets past purchases
  // Future<void> _getPastPurchases() async {
  //   await _inAppPurchase.restorePurchases();
  //
  //   // for (PurchaseDetails purchase in response.pastPurchases) {
  //   // if (Platform.isIOS) {
  //   // InAppPurchase.instance.completePurchase(purchase);
  //   // }
  //   // }
  //   // print('purchase response is: $response');
  //   // print('purchase response pastPurchases: ${response.pastPurchases}');
  //   // print('purchase response error: ${response.error}');
  //   // if (response.error != null) print ('error message: ${response.error.message}');
  //   // _purchases = response.pastPurchases;
  //   //
  //   // if (response.pastPurchases == null) {
  //   // print('response.pastPurchases = NULL');
  //   // } else {
  //   // print('purchase response pastPurchases length: ${response.pastPurchases.length}');
  //   // }
  //   //
  //   // if (Platform.isAndroid) {
  //   // print('PURCHASES:');
  //   // _purchases.forEach((purchase) {
  //   // print(
  //   // 'purchase id: ${purchase.status}, purchase status: ${purchase
  //   //     .status}');
  //   // var purchaseData = purchase.verificationData.localVerificationData;
  //   // var purchaseDataDecoded = jsonDecode(
  //   // purchase.verificationData.localVerificationData);
  //   // print('purchase data: $purchaseData');
  //   // var purchaseId = purchaseDataDecoded["orderId"];
  //   // var purchaseProductId = purchaseDataDecoded["productId"];
  //   // var purchaseStatus = purchaseDataDecoded["purchaseState"];
  //   // print('purchaseId: $purchaseId, purchaseProductId: $purchaseProductId, purchaseStatus: $purchaseStatus');
  //   // });
  //   // }
  // }

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
  }

  /// Purchase a product
  void buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//    _connection.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  /// Consume purchase
// void consume(PurchaseDetails purchase) async {
//   // Bring ads back
//   _setMainPageState(isAdsRemoved: false);
//   _prefs.setBool(Constants.IS_AD_REMOVED_KEY, false);
//
//   // Mark purchase consumed
//   BillingResponse res = await _inAppPurchase.consumePurchase(purchase);
//   print('Result of consuming is $res');
//   await _getPastPurchases();
// }

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
    _purchases = [];
    _purchasePending = false;

    bool? isAdRemovedPref = _prefs.getBool(Constants.IS_AD_REMOVED_KEY);

    if (isAdRemovedPref == null || isAdRemovedPref == false) {
      _setMainPageState(isAdsRemoved: false);
    } else {
      _setMainPageState(isAdsRemoved: true);
    }
  }
}
