# Contributing Guide

EscapeWild.Flutter is a Flutter project and works on all platforms,
including Android, Windows, Linux, macOS and iOS.

- Want to build EscapeWild.Flutter? Please see [the building guide](#how-to-build).
- Want to work on Localization? Please see [localization](#Localization).

## How to build

There's a few resources to get you started if you are not familiar with Flutter.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online documentation](https://docs.flutter.dev/)

## Localization

EscapeWild.Flutter uses [easy_localization](https://pub.dev/packages/easy_localization) package,
and it will retrieve localization files in [assets](escape_wild/assets).

The localization is formatted in [yaml](https://yaml.org/), which has a good-looking syntax.

### Your language is not here?

If your language is not under [l10n folder](escape_wild/assets/l10n),
please follow this step-by-step guide to create it.

1. Copy the [en.yaml](escape_wild/assets/l10n/en.yaml) and paste in the same folder with a different name,
   for example, if the target language is French, you should rename it to `fr.yaml`.

2. Now do the localization! Just translate all English words to your language.
3. Please keep it in the same ordered as [en.yaml](escape_wild/assets/l10n/en.yaml).
4. Finally, add locale into `R.supporrtedLocales` in [R class](escape_wild/lib/r.dart).
   ```dart
   static const supportedLocales = [
    defaultLocale,
    const Locale("fr"), // add this
   ];
   ``` 

### Contribute to an existed localization

If your language is under [l10n folder](escape_wild/assets/l10n),
but it lacks further localization, or you want to improve it, please follow this step-by-step guide.

1. Find it under [l10n folder](escape_wild/assets/l10n).
2. Now do the localization! For missing words,
   you can just copy from the default localization in [en.yaml](escape_wild/assets/l10n/en.yaml).
3. Please keep it in the same ordered as [en.yaml](escape_wild/assets/l10n/en.yaml).
