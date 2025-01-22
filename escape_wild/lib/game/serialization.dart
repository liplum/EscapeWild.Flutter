import 'package:jconverter/jconverter.dart';

// ignore: non_constant_identifier_names
final Cvt = JConverter();

List<T> deserializeList<T extends JConvertibleProtocol>(dynamic json) {
  final res = <T>[];
  for (final e in json as List) {
    final restored = Cvt.fromJsonObj<T>(e);
    res.add(restored!);
  }
  return res;
}
