import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';

void registerTypes(JConverter cvt) {
  cvt.addAuto(Backpack.type, Backpack.fromJson);
}
