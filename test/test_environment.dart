import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Contains various constants and functions to support testing.
class TestEnvironment {
  /// Contains multiple [Device] used for golden tests.
  /// First [Device] represents Android whereas [Device.iphone11] represents iOS.
  static const goldenDevices = [
    Device(name: 'android', size: Size(375, 667)),
  ];

  /// Wrapper for golden tests.
  static Widget widgetTestWrapperGolden(Widget child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: Material(child: child),
      );

  /// Wrapper for widget tests.
  static Widget widgetTestWrapper({
    required Widget child,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Material(child: child),
    );
  }
}
