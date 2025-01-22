import 'dart:ui';

import 'package:escape_wild/core/index.dart';

// ignore: non_constant_identifier_names
final I18n = I18nImpl();

class I18nImpl {
  final defaultNamespace = Vanilla.instance.modId;
  final Map<String, L10nProvider> _namespace2L10n = {};

  void load(String namespace, L10nProvider l10n) {
    _namespace2L10n[namespace] = l10n;
  }

  void unload(String namespace) {
    _namespace2L10n.remove(namespace);
  }

  String get(String namespace, String key) {
    final l10n = _namespace2L10n[namespace];
    if (l10n == null) return key;
    return l10n.tryGetL10n(key) ?? key;
  }

  String operator [](String key) {
    return get(defaultNamespace, key);
  }
}

final RegExp _replaceArgRegex = RegExp('{}');

extension StringFormattX on String {
  String format(List<String> args) {
    if (args.isEmpty) return this;
    var res = this;
    for (var arg in args) {
      res = res.replaceFirst(_replaceArgRegex, arg);
    }
    return res;
  }

  String format1(String arg0) {
    return replaceFirst(_replaceArgRegex, arg0);
  }

  String format2(String arg0, String arg1) {
    var res = this;
    res = replaceFirst(_replaceArgRegex, arg0);
    res = replaceFirst(_replaceArgRegex, arg1);
    return res;
  }

  String format3(String arg0, String arg1, String arg2) {
    var res = this;
    res = replaceFirst(_replaceArgRegex, arg0);
    res = replaceFirst(_replaceArgRegex, arg1);
    res = replaceFirst(_replaceArgRegex, arg2);
    return res;
  }
}

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
    score += 6;
  }
  if (target.scriptCode == test.scriptCode) {
    score += 3;
  }
  return score;
}
