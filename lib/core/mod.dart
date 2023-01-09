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
