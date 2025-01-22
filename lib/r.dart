import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:platform_safe_func/platform_safe_func.dart';

class R {
  R._();

  static const defaultLocale = Locale('en');
  static const zhCnLocale = Locale('zh', "CN");
  static const frLocale = Locale('fr');
  static const supportedLocales = [
    defaultLocale,
    zhCnLocale,
    frLocale,
  ];
  static const debugMode = kDebugMode;
  static const packageName = "net.liplum.escape_wild.flutter";
  static late final String appDir;
  static late final String tmpDir;

  static String get localStorageDir => isDesktop ? joinPath(appDir, packageName) : appDir;

  static String get hiveDir => joinPath(localStorageDir, "hive");
  static const disabledAlpha = 0.4;
  static const healthColor = Color(0xfffc3545);
  static const foodColor = Color(0xfffeaa1a);
  static const waterColor = Color(0xff1ca3ec);
  static const energyColor = Color(0xfffbad67);
  static const flameColor = Color(0xffe25822);
  static const fuelYellowColor = Color(0xffefa537);
}
