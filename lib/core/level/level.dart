import 'package:escape_wild/core/index.dart';
import 'package:jconverter/jconverter.dart';

abstract class LevelMetaProtocol {
  static final LevelMetaProtocol empty = _EmptyLevelMeta();
  final String name;

  LevelMetaProtocol(this.name);

  LevelProtocol create();
}

abstract class LevelProtocol implements JConvertibleProtocol {
  static final LevelProtocol empty = _EmptyLevel();

  Hardness get hardness;

  List<PlaceAction> getAvailableActions();

  Future<void> performAction(UserAction action);

  Future<void> onPassTime(Ts delta);

  PlaceProtocol restoreLastLocation(locationRestoreId);

  dynamic getLocationRestoreId(PlaceProtocol place);

  void onRestore();

  void onGenerateRoute();
}

class _EmptyLevelMeta extends LevelMetaProtocol {
  _EmptyLevelMeta() : super("empty");

  @override
  LevelProtocol create() => .empty;
}

class _EmptyLevel extends LevelProtocol {
  @override
  List<PlaceAction> getAvailableActions() {
    return const [];
  }

  @override
  Future<void> performAction(UserAction action) async {
    player.actionTimes++;
  }

  @override
  Future<void> onPassTime(Ts delta) async {}

  @override
  String get typeName => "EmptyLevel";

  @override
  getLocationRestoreId(PlaceProtocol place) {
    throw UnimplementedError();
  }

  @override
  Hardness get hardness => .normal;

  @override
  void onRestore() {}

  @override
  PlaceProtocol restoreLastLocation(locationRestoreId) {
    throw UnimplementedError();
  }

  @override
  void onGenerateRoute() {}
}
