import 'package:json_annotation/json_annotation.dart';

abstract class ModProtocol {
  String get modId;

  String decorateRegisterName(String name);
}

extension ModProtocolX on ModProtocol {
  bool get isVanilla => identical(this, Vanilla.instance);
}

class Mod implements ModProtocol {
  @override
  final String modId;

  Mod(this.modId);

  @override
  String decorateRegisterName(String name) => "$modId-name";
}

class Vanilla implements ModProtocol {
  Vanilla._();

  static final instance = Vanilla._();

  @override
  String get modId => "vanilla";

  @override
  String decorateRegisterName(String name) => name;
}

mixin Moddable {
  @JsonKey(ignore: true)
  ModProtocol mod = Vanilla.instance;
}

extension ModdableX on Moddable {
  bool get isVanilla => mod.isVanilla;

  bool get isModded => !mod.isVanilla;
}
