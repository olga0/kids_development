import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kids_development/const.dart';
import 'package:kids_development/cubits/main/main_cubit.dart';
import 'package:kids_development/cubits/main/main_state.dart';
import 'package:mockito/mockito.dart';

import 'main_feature.mocks.dart';

void main() {
  late MockPurchaseManager purchaseManager;
  late MockSharedPreferences sharedPreferences;
  late MockAdsManager adsManager;
  ProductDetails product = ProductDetails(
    id: 'id',
    title: 'title',
    description: 'description',
    price: 'price',
    rawPrice: 10.0,
    currencyCode: 'currencyCode',
  );

  MainState loadedStateAdsRemoved = MainState.loaded(
    isAdRemoved: true,
    chosenLanguage: 'en',
    localeLanguage: 'en',
  );

  MainState loadedStateAdsNotRemoved = MainState.loaded(
    isAdRemoved: false,
    chosenLanguage: 'en',
    localeLanguage: 'en',
  );

  setUp(() {
    purchaseManager = MockPurchaseManager();
    sharedPreferences = MockSharedPreferences();
    adsManager = MockAdsManager();
    when(purchaseManager.purchaseStateStream)
        .thenAnswer((_) => const Stream.empty());
    when(purchaseManager.initializePurchaseData())
        .thenAnswer((_) => Future.value(true));
  });

  group('Constructor', () {
    test('Cubit initially loading', () async {
      final cubit = MainCubit(
        sharedPreferences: sharedPreferences,
        adsManager: adsManager,
        purchaseManager: purchaseManager,
      );
      expect(cubit.state, const MainState.loading());
    });
  });

  group('load()', () {
    blocTest<MainCubit, MainState>(
      'Not called when loaded',
      build: () => MainCubit.test(
        state: loadedStateAdsRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
        setUpSubscriptions: false,
      ),
      act: (cubit) => cubit.load(),
      verify: (_) => [verifyNever(purchaseManager.purchaseStateStream)],
      expect: () => [],
    );

    blocTest<MainCubit, MainState>(
      'Successfully loads when MainState is loading',
      setUp: () {
        when(purchaseManager.purchaseStateStream)
            .thenAnswer((_) => Stream.value(true));
        when(sharedPreferences.getString(Constants.CHOSEN_LANGUAGE_KEY))
            .thenReturn('en');
        when(sharedPreferences.getString(Constants.LOCALE_LANGUAGE_KEY))
            .thenReturn('en');
      },
      build: () => MainCubit.test(
        state: MainState.loading(),
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.load(),
      verify: (_) => [
        verify(purchaseManager.purchaseStateStream).called(1),
        verify(sharedPreferences.getString(Constants.CHOSEN_LANGUAGE_KEY))
            .called(1),
      ],
      expect: () => [loadedStateAdsRemoved],
    );
  });

  group('buyProduct(ProductDetails)', () {
    blocTest<MainCubit, MainState>(
      'Not called when loading',
      build: () => MainCubit.test(
        state: MainState.loading(),
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
        setUpSubscriptions: false,
      ),
      act: (cubit) => cubit.buyProduct(product),
      verify: (_) => [verifyNever(purchaseManager.buyProduct(any))],
      expect: () => [],
    );

    blocTest<MainCubit, MainState>(
      'buyProduct called when loaded and ad not removed',
      build: () => MainCubit.test(
        state: loadedStateAdsNotRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.buyProduct(product),
      verify: (_) => [
        verify(purchaseManager.buyProduct(product)).called(1),
      ],
    );

    blocTest<MainCubit, MainState>(
      'buyProduct not called when loaded and ad removed',
      build: () => MainCubit.test(
        state: loadedStateAdsRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.buyProduct(product),
      verify: (_) => [
        verifyNever(purchaseManager.buyProduct(product)),
      ],
    );
  });

  group('showAd()', () {
    blocTest<MainCubit, MainState>(
      'Not called when loading',
      build: () => MainCubit.test(
        state: MainState.loading(),
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
        setUpSubscriptions: false,
      ),
      act: (cubit) => cubit.showAd(),
      verify: (_) => [verifyNever(adsManager.showAds())],
    );

    blocTest<MainCubit, MainState>(
      'showAds called when loaded and ad not removed',
      build: () => MainCubit.test(
        state: loadedStateAdsNotRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.showAd(),
      verify: (_) => [
        verify(adsManager.showAds()).called(1),
      ],
    );

    blocTest<MainCubit, MainState>(
      'showAds not called when loaded and ad removed',
      build: () => MainCubit.test(
        state: loadedStateAdsRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.showAd(),
      verify: (_) => [
        verifyNever(adsManager.showAds()),
      ],
    );
  });

  group('setLanguage(String)', () {
    blocTest<MainCubit, MainState>(
      'Successfully sets a language when loaded',
      build: () => MainCubit.test(
        state: loadedStateAdsRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.setLanguage('language'),
      expect: () => [
        MainState.loaded(
            isAdRemoved: true,
            chosenLanguage: 'language',
            localeLanguage: 'en'),
      ],
    );

    blocTest<MainCubit, MainState>(
      'Not called when loading',
      build: () => MainCubit.test(
        state: MainState.loading(),
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      ),
      act: (cubit) => cubit.setLanguage('language'),
      expect: () => [],
    );
  });

  group('.adsProduct', () {
    test('Successfully returns a product', () {
      when(purchaseManager.getAdsProduct()).thenReturn(product);
      final cubit = MainCubit.test(
        state: loadedStateAdsRemoved,
        sharedPreferences: sharedPreferences,
        purchaseManager: purchaseManager,
        adsManager: adsManager,
      );
      expect(cubit.adsProduct, product);
    });
  });
}
