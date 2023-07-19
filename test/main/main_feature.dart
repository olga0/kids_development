import 'package:kids_development/ads_manager.dart';
import 'package:kids_development/purchase_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  SharedPreferences,
  PurchaseManager,
  AdsManager,
])
// ignore: unused_element
class _GenerateMocks {}