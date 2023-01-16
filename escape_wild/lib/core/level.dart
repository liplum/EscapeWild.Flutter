import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';

abstract class LevelMetaProtocol with Moddable {
  static final LevelMetaProtocol empty = _EmptyLevelMeta();
  @override
  final String name;

  LevelMetaProtocol(this.name);

  LevelProtocol create();
}

abstract class LevelProtocol implements JConvertibleProtocol {
  static final LevelProtocol empty = _EmptyLevel();

  Hardness get hardness;

  List<PlaceAction> getAvailableActions();

  Future<void> performAction(UAction action);

  Future<void> onPass(TS delta);

  PlaceProtocol restoreLastLocation(locationRestoreId);

  dynamic getLocationRestoreId(PlaceProtocol place);

  void onRestore();

  void onGenerateRoute();
}

class _EmptyLevelMeta extends LevelMetaProtocol {
  _EmptyLevelMeta() : super("empty");

  @override
  LevelProtocol create() => LevelProtocol.empty;
}

class _EmptyLevel extends LevelProtocol {
  @override
  List<PlaceAction> getAvailableActions() {
    return const [];
  }

  @override
  Future<void> performAction(UAction action) async {
    player.actionTimes++;
  }

  @override
  Future<void> onPass(TS delta) async {}

  @override
  String get typeName => "EmptyLevel";

  @override
  getLocationRestoreId(PlaceProtocol place) {
    throw UnimplementedError();
  }

  @override
  Hardness get hardness => Hardness.normal;

  @override
  void onRestore() {}

  @override
  PlaceProtocol restoreLastLocation(locationRestoreId) {
    throw UnimplementedError();
  }

  @override
  void onGenerateRoute() {}
}
