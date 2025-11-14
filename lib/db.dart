import 'package:hive_flutter/hive_flutter.dart';

// ignore: non_constant_identifier_names
final DB = DBImpl._();

class DBImpl {
  DBImpl._();

  late final Box<String> $gameSave;
  final preference = Preference();

  Future<void> init() async {
    $gameSave = await Hive.openBox("GameSave");
    preference.box = await Hive.openBox("Preference");
  }

  String? getGameSave({int slot = 0}) => $gameSave.get(slot);

  Future<void> setGameSave(String save, {int slot = 0}) => $gameSave.put(slot, save);

  Future<void> deleteGameSave({int slot = 0}) => $gameSave.delete(slot);
}

class Preference {
  late final Box<dynamic> box;

  String? getMeasurementSystemOf(String name) => box.get("measurement-system.$name");

  Future<void> setMeasurementSystemOf(String name, String? v) => box.put("measurement-system.$name", v);
}
