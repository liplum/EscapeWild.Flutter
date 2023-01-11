import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';

//part 'cole_temperate_zone.g.dart';

class SubFrigidZoneRouteGenerator extends RouteGeneratorProtocol {
  @override
  RouteProtocol generateRoute(RouteGenerateContext ctx) {
    // TODO: implement generateRoute
    throw UnimplementedError();
  }
}

class SubFrigidZoneRoute extends RouteProtocol {
  double routeProgress = 0.0;

  double getRouteProgress() => routeProgress;

  @override
  // TODO: implement initialPlace
  PlaceProtocol get initialPlace => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();
}

class SubFrigidZonePlace extends PlaceProtocol with PlaceActionDelegateMixin {
  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement route
  RouteProtocol get route => throw UnimplementedError();

  @override
  // TODO: implement typeName
  String get typeName => throw UnimplementedError();

  @override
  List<PlaceAction> getAvailableActions() {
    // TODO: implement getAvailableActions
    throw UnimplementedError();
  }
}

class IceSheet extends SubFrigidZonePlace {}

class Snowfield extends SubFrigidZonePlace {}

class Rivers extends SubFrigidZonePlace {}

class ConiferousForest extends SubFrigidZonePlace {}

class BrownBearNest extends SubFrigidZonePlace {}

class Tundra extends SubFrigidZonePlace {}
