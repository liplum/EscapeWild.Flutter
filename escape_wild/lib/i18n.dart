import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core.dart';
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
  static const _t = "time";

  static String timeMinuteOf(String min) => "$_t.minute".tr(args: [min]);

  static String timeHourOf(String hour) => "$_t.hour".tr(args: [hour]);

  static String timeHmOf(String hour, String minute) => "$_t.hm".tr(namedArgs: {
        "hour": hour,
        "min": minute,
      });

  static String ts(TS ts) {
    final hour = ts.hourPart;
    if (hour <= 0) {
      return timeMinuteOf(ts.minutes.toString());
    } else {
      return timeHmOf(hour.toString(), ts.minutePart.toString());
    }
  }
}

class _Action {
  static const _n = "action";

  String gotItems(String items) => "$_n.got-items".tr(args: [items]);

  String get gotNothing => "$_n.got-nothing".tr();

  String toolBroken(String tool) => "$_n.tool-broken".tr(args: [tool]);
}

class PhysicalQuantity {
  final String name;

  const PhysicalQuantity(this.name);

  static const mass = PhysicalQuantity("mass"),
      length = PhysicalQuantity("length"),
      temperature = PhysicalQuantity("temperature");
  static const all = [
    mass,
    length,
    temperature,
  ];

  @override
  String toString() => name;
}

extension PhysicalQuantityX on PhysicalQuantity {
  String l10nName() => "physical-quantity.$name".tr();
}

abstract class UnitConverter {
  final PhysicalQuantity quantity;
  final String name;

  const UnitConverter(this.quantity, this.name);

  String l10nName();

  String l10nUnit();

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
  static final Map<String, UnitConverter> name2Cvt$Mass = {
    "gram": gram,
    "kilogram": kilogram,
    "pound": pound,
    "ounce": ounce,
  };

  static UnitConverter getMassForName(String? name) => name2Cvt$Mass[name] ?? gram;
  static final Map<PhysicalQuantity, List<UnitConverter>> measurement2Converters = {
    PhysicalQuantity.mass: [gram, kilogram, pound, ounce],
  };
}

class _UnitConverterImpl extends UnitConverter {
  final num Function(int gram) converter;
  final int maxTrailingZero;

  const _UnitConverterImpl(
    super.quantity,
    super.name,
    this.converter, {
    this.maxTrailingZero = 2,
  });

  const _UnitConverterImpl.mass(
    String name,
    this.converter, {
    this.maxTrailingZero = 2,
  }) : super(PhysicalQuantity.mass, name);

  @override
  num convertToNum(int gram) => converter(gram);

  @override
  String convertWithUnit(int gram) {
    if (gram == 0) {
      return withUnit("0");
    }
    final target = converter(gram);
    if (target is int) {
      return withUnit("$target");
    } else {
      final formatted = target.toStringAsFixed(maxTrailingZero);
      return withUnit(removeTrailingZeros(formatted));
    }
  }

  String removeTrailingZeros(String s) {
    var lastNotZeroIndex = 0;
    for (var i = 0; i < s.length; i++) {
      final char = s[i];
      if (char != "0") {
        lastNotZeroIndex = i;
      }
    }
    if (s[lastNotZeroIndex] == ".") {
      lastNotZeroIndex--;
    }
    return s.substring(0, lastNotZeroIndex + 1);
  }

  String withUnit(String number) {
    return "unit.$quantity.$name.format".tr(args: [number]);
  }

  @override
  String l10nName() => "unit.$quantity.$name.name".tr();

  @override
  String l10nUnit() => "unit.$quantity.$name.unit".tr();
}
