import 'package:escape_wild/game/route/subtropics.dart' as s;
import 'package:jconverter/jconverter.dart';

void registerTypes(JConverter cvt) {
  cvt.addAuto(s.SubtropicsRoute.type, s.SubtropicsRoute.fromJson);
  cvt.addAuto(s.SubtropicsPlace.type, s.SubtropicsPlace.fromJson);
  cvt.addAuto(s.PlainPlace.type, s.PlainPlace.fromJson);
  cvt.addAuto(s.ForestPlace.type, s.ForestPlace.fromJson);
  cvt.addAuto(s.RiversidePlace.type, s.RiversidePlace.fromJson);
  cvt.addAuto(s.CavePlace.type, s.CavePlace.fromJson);
  cvt.addAuto(s.HutPlace.type, s.HutPlace.fromJson);
}
