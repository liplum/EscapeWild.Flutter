import 'package:hive_flutter/hive_flutter.dart';

// ignore: non_constant_identifier_names
final DB = DBImpl._();

class DBImpl {
  DBImpl._();

  late final Box<String> $gameSave;

  Future<void> init() async {
    $gameSave = await Hive.openBox("GameSave");
  }

  String? getGameSave({int slot = 0}) => $gameSave.get(slot);

  setGameSave(String save, {int slot = 0}) => $gameSave.put(slot, save);

  deleteGameSave({int slot = 0}) => $gameSave.delete(slot);
}
