import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';

class I {
  I._();

  static final action = _Action();

  static String massOf(int gram) => Measurement.mass.convertWithUnit(gram);

  static String get done => "done".tr();

  static String get ok => "ok".tr();

  static String get yes => "yes".tr();

  static String get no => "no".tr();

  static String get notNow => "not-now".tr();

  static String get cancel => "cancel".tr();

  static String get alright => "alright".tr();

  static String get discard => "discard".tr();
}

class _Action {
  static const _n = "action";

  String gotItems(String items) => "$_n.got-items".tr(args: [items]);

  String get gotNothing => "$_n.got-nothing".tr();

  String toolBroken(String tool) => "$_n.tool-broken".tr(args: [tool]);
}

abstract class UnitConverter {
  String l10nName();

  num convertToNum(int si);

  String convertWithUnit(int si);

  static const gram2PoundUnit = 0.0022046226;
  static const gram2OunceUnit = 0.03527396195;
  static final UnitConverter gram = _UnitConverterImpl.mass(
        "gram",
        (gram) => gram,
      ),
      kilogram = _UnitConverterImpl.mass(
        "kilogram",
        (gram) => gram / 1000,
      ),
      pound = _UnitConverterImpl.mass(
        "pound",
        (gram) => gram * gram2PoundUnit,
      ),
      ounce = _UnitConverterImpl.mass(
        "ounce",
        (gram) => gram * gram2OunceUnit,
      );
  static final Map<String, UnitConverter> name2MassCvt = {
    "gram": gram,
    "kilogram": kilogram,
    "pound": pound,
    "ounce": ounce,
  };

  static UnitConverter getMassForName(String? name) => name2MassCvt[name] ?? gram;
  static final Map<String, List<UnitConverter>> measurement2Converters = {
    "mass": [gram, kilogram, pound, ounce],
  };
}

class _UnitConverterImpl implements UnitConverter {
  final String physicalQuantity;
  final String name;
  final num Function(int gram) converter;
  final int fixedDigit;

  const _UnitConverterImpl(
    this.physicalQuantity,
    this.name,
    this.converter, {
    this.fixedDigit = 2,
  });

  const _UnitConverterImpl.mass(
    this.name,
    this.converter, {
    this.fixedDigit = 2,
  }) : physicalQuantity = "mass";

  @override
  num convertToNum(int gram) => converter(gram);

  @override
  String convertWithUnit(int gram) {
    final target = converter(gram);
    if (target is int) {
      return withUnit("$target");
    } else {
      return withUnit(target.toStringAsFixed(fixedDigit));
    }
  }

  String withUnit(String number) {
    return "unit.$physicalQuantity.$name.format".tr(args: [number]);
  }

  @override
  String l10nName() => "unit.$physicalQuantity.$name.name".tr();
}
