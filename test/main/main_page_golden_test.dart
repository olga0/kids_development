import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kids_development/ads_manager.dart';
import 'package:kids_development/const.dart';
import 'package:kids_development/cubits/main/main_cubit.dart';
import 'package:kids_development/cubits/main/main_state.dart';
import 'package:kids_development/levels/main_page.dart';
import 'package:kids_development/levels/odd_one_out_page.dart';
import 'package:kids_development/purchase_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_environment.dart';
import 'main_feature.mocks.dart';

Future<void> main() async {
  late MockAdsManager adsManager;
  late MockPurchaseManager purchaseManager;
  late MockSharedPreferences sharedPreferences;
  late MockNavigatorObserver navigatorObserver;

  setUp(() {
    adsManager = MockAdsManager();
    purchaseManager = MockPurchaseManager();
    sharedPreferences = MockSharedPreferences();
    navigatorObserver = MockNavigatorObserver();
    when(purchaseManager.purchaseStateStream).thenAnswer((_) => Stream.empty());
    when(purchaseManager.getAdsProduct()).thenReturn(ProductDetails(
      id: 'id',
      title: 'title',
      description: 'description',
      price: 'price',
      rawPrice: 10.0,
      currencyCode: 'currencyCode',
    ));
    when(sharedPreferences.setString(any, any))
        .thenAnswer((_) => Future.value(true));
  });

  testGoldens('Golden - States', (tester) async {
    await loadAppFonts();
    await tester.pumpDeviceBuilder(
      DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: TestEnvironment.goldenDevices,
        )
        ..addScenario(
            name: 'Loading',
            widget: _widget(
              adsManager: adsManager,
              purchaseManager: purchaseManager,
              sharedPreferences: sharedPreferences,
              state: MainState.loading(),
            ))
        ..addScenario(
          name: 'Loaded with ads removed',
          widget: _widget(
            adsManager: adsManager,
            purchaseManager: purchaseManager,
            sharedPreferences: sharedPreferences,
            state: MainState.loaded(
              isAdRemoved: true,
              chosenLanguage: 'en',
              localeLanguage: 'en',
            ),
          ),
        )
        ..addScenario(
          name: 'Loaded with ads not removed',
          widget: _widget(
            adsManager: adsManager,
            purchaseManager: purchaseManager,
            sharedPreferences: sharedPreferences,
            state: MainState.loaded(
              isAdRemoved: false,
              chosenLanguage: 'en',
              localeLanguage: 'en',
            ),
          ),
        ),
      wrapper: TestEnvironment.widgetTestWrapperGolden,
    );
    await screenMatchesGolden(
      tester,
      'golden_main_page_states',
    );
  });

  testGoldens('Golden - Language dialog', (tester) async {
    await loadAppFonts();
    await tester.pumpDeviceBuilder(
      DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: TestEnvironment.goldenDevices,
        )
        ..addScenario(
          name: 'Show language dialog',
          widget: _widget(
            adsManager: adsManager,
            purchaseManager: purchaseManager,
            sharedPreferences: sharedPreferences,
            state: MainState.loaded(
              isAdRemoved: true,
              chosenLanguage: 'en',
              localeLanguage: 'en',
            ),
          ),
          onCreate: (scenarioWidgetKey) async {
            await tester.tap(find.descendant(
              of: find.byKey(scenarioWidgetKey),
              matching: find.byIcon(Icons.language),
            ));
            await tester.pumpAndSettle();
          },
        ),
      wrapper: TestEnvironment.widgetTestWrapperGolden,
    );
    await screenMatchesGolden(
      tester,
      'golden_main_page_language_dialog',
    );
  });

  group('Interaction', () {
    testWidgets(
      'Changing language',
      (tester) async {
        await tester.pumpWidget(_testerWidget(
          adsManager: adsManager,
          purchaseManager: purchaseManager,
          sharedPreferences: sharedPreferences,
          navigatorObserver: navigatorObserver,
          state: MainState.loaded(
            isAdRemoved: true,
            chosenLanguage: 'en',
            localeLanguage: 'en',
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.language));
        await tester.pumpAndSettle();
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();
        verify(sharedPreferences.setString(Constants.CHOSEN_LANGUAGE_KEY, 'en'))
            .called(1);
      },
    );
  });

  group('Navigation', () {
    testWidgets(
      'Navigate to OddOneOut page',
      (tester) async {
        when(navigatorObserver.navigator).thenReturn(null);
        await tester.pumpWidget(_testerWidget(
          adsManager: adsManager,
          purchaseManager: purchaseManager,
          sharedPreferences: sharedPreferences,
          navigatorObserver: navigatorObserver,
          state: MainState.loaded(
            isAdRemoved: true,
            chosenLanguage: 'en',
            localeLanguage: 'en',
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(MainPage.keyOddOneOutButton));
        await tester.pumpAndSettle();
        verify(navigatorObserver.didPush(any, any)).called(2);
        expect(find.byType(OddOneOutPage), findsOneWidget);
      },
    );
  });
}

Widget _testerWidget({
  required AdsManager adsManager,
  required PurchaseManager purchaseManager,
  required SharedPreferences sharedPreferences,
  required NavigatorObserver navigatorObserver,
  MainState? state,
}) =>
    TestEnvironment.widgetTestWrapper(
      child: _widget(
        adsManager: adsManager,
        purchaseManager: purchaseManager,
        sharedPreferences: sharedPreferences,
        state: state,
      ),
      navigatorObserver: navigatorObserver,
    );

Widget _widget({
  required AdsManager adsManager,
  required PurchaseManager purchaseManager,
  required SharedPreferences sharedPreferences,
  MainState? state,
}) =>
    MultiProvider(
      providers: [
        Provider<AdsManager>.value(value: adsManager),
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<PurchaseManager>.value(value: purchaseManager),
      ],
      child: state != null
          ? BlocProvider(
              create: (_) => MainCubit.test(
                state: state,
                purchaseManager: purchaseManager,
                sharedPreferences: sharedPreferences,
                adsManager: adsManager,
              ),
              child: MainPage(),
            )
          : MainPage(),
    );
