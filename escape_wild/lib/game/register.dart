import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/route/subtropics.dart' as s;

void registerTypes() {
  Cvt.registerConvertibleAuto(s.SubtropicsRoute.type, s.SubtropicsRoute.fromJson);
  Cvt.registerConvertibleAuto(s.SubtropicsPlace.type, s.SubtropicsPlace.fromJson);
  Cvt.registerConvertibleAuto(s.PlainPlace.type, s.PlainPlace.fromJson);
  Cvt.registerConvertibleAuto(s.ForestPlace.type, s.ForestPlace.fromJson);
  Cvt.registerConvertibleAuto(s.RiversidePlace.type, s.RiversidePlace.fromJson);
  Cvt.registerConvertibleAuto(s.CavePlace.type, s.CavePlace.fromJson);
  Cvt.registerConvertibleAuto(s.HutPlace.type, s.HutPlace.fromJson);
}
