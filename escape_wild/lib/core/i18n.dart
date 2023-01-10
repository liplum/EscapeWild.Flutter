import 'dart:ui';

import 'package:escape_wild/i18n.dart';

abstract class L10nProvider {
  String? tryGetL10n(String key);
}

abstract class I18nScopeProtocol {
  String get i18nNamespace;
}

extension I18nScopeProtocolX on I18nScopeProtocol {
  String i18n(String key) {
    return I18n.get(i18nNamespace, key);
  }
}
/// Prerequisites: [candidates] is not empty.
Locale tryFindBestMatchedLocale(Locale target, Locale defaultLocale, List<Locale> candidates) {
  if (candidates.isEmpty) {
    throw ArgumentError("`candidates` is an empty list.");
  }
  // now candidate list is not empty
  if (candidates.length == 1) {
    return candidates.first;
  }
  Locale? res;
  var maxScore = 0;
  for (final candidate in candidates) {
    final score = _evaluateLocaleMatchScore(target, candidate);
    if (score > maxScore) {
      maxScore = score;
      res = candidate;
    }
  }
  if (res != null) return res;
  // now try to match default locale
  for (final candidate in candidates) {
    final score = _evaluateLocaleMatchScore(defaultLocale, candidate);
    if (score > maxScore) {
      maxScore = score;
      res = candidate;
    }
  }
  // if still not matched, return the first one.
  return res ?? candidates.first;
}

int _evaluateLocaleMatchScore(Locale target, Locale test) {
  var score = 0;
  if (target.languageCode == test.languageCode) {
    score += 10;
  }
  if (target.countryCode == test.countryCode) {
    score += 8;
  }
  if (target.scriptCode == test.scriptCode) {
    score += 5;
  }
  return score;
}
