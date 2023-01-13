import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:escape_wild/utils/collection.dart';
import 'dart:math';

//part 'cole_temperate_zone.g.dart';

class SubFrigidZoneRouteGenerator extends RouteGeneratorProtocol {
  @override
  RouteProtocol generateRoute(RouteGenerateContext ctx, int seed) {
    var map2d = list2dOf<SubFrigidZonePlace>(50, 1, (x, y) {
      return SubFrigidZonePlace("??????");
    });
    for (int a = 0; a <= 50; a++) {
      final yRoute = SubFrigidZoneRoute("$a column subfrigid_zone");
      int countNum = 50;
      var randomNum = Random();
      List<double> saveRDN = [];
      for (int d = 0; d <= 6; d++) {
        int rdn = randomNum.nextInt(countNum);
        countNum -= rdn;
        double num = rdn / 50;
        saveRDN.add(num);
      }
    }

    throw UnimplementedError();
  }

  List<SubFrigidZonePlace> genIceSheet(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = IceSheet("icesheet");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genSnowfield(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = IceSheet("icesheet");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genRivers(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = IceSheet("icesheet");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genSwamp(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = IceSheet("icesheet");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genConiferousForest(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = IceSheet("icesheet");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> Tundra(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = IceSheet("icesheet");
      res.add(place);
    }
    return res;
  }
}

class SubFrigidZoneRoute extends RouteProtocol {
  @override
  final String name;

  SubFrigidZoneRoute(this.name);

  List<SubFrigidZonePlace> places = [];

  int get placeCount => places.length;

  double routeProgress = 0.0;

  double getRouteProgress() => routeProgress;

  void add(SubFrigidZonePlace place) {
    places.add(place);
    place.route = this;
  }

  void addAll(Iterable<SubFrigidZonePlace> places) {
    for (final place in places) {
      add(place);
    }
  }

  void replaceRange(int index, SubFrigidZonePlace place) {
    places[index] = place;
    place.route = this;
  }

  @override
  // TODO: implement initialPlace
  PlaceProtocol get initialPlace => places[0];

  @override
  void onRestored() {
    for (final place in places) {
      place.route = this;
    }
  }

  @override
  getRestoreIdOf(covariant PlaceProtocol place) {
    return places.indexOfAny(place);
  }

  @override
  PlaceProtocol restoreById(restoreId) {
    return places[(restoreId as int).clamp(0, places.length - 1)];
  }

  static const String type = "SubFrigidZoneRoute";

  @override
  String get typeName => type;
}

@JsonSerializable()
class SubFrigidZonePlace extends PlaceProtocol with PlaceActionDelegateMixin {
  @override
  @JsonKey()
  String name;

  SubFrigidZonePlace(this.name);

  @override
  @JsonKey(ignore: true)
  late SubFrigidZoneRoute route;

  @JsonKey()
  int exploreCount = 0;

  static const type = "SubFrigidZone";

  @override
  String get typeName => type;

  @override
  List<PlaceAction> getAvailableActions() {
    return [
      PlaceAction.moveWithEnergy,
      PlaceAction.exploreWithEnergy,
      PlaceAction.rest,
      PlaceAction.huntWithTool,
    ];
  }
}

class IceSheet extends SubFrigidZonePlace {
  IceSheet(super.name);
}

class Snowfield extends SubFrigidZonePlace {
  Snowfield(super.name);
}

class Rivers extends SubFrigidZonePlace {
  Rivers(super.name);
}

class ConiferousForest extends SubFrigidZonePlace {
  ConiferousForest(super.name);
}

class BrownBearNest extends SubFrigidZonePlace {
  BrownBearNest(super.name);
}

class Tundra extends SubFrigidZonePlace {
  Tundra(super.name);
}

class Swamp extends SubFrigidZonePlace {
  Swamp(super.name);
}
