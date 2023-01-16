import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:escape_wild/utils/collection.dart';
import 'dart:math';

import 'package:noitcelloc/noitcelloc.dart';

part 'subfrigid_zone.g.dart';

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
      final place = Snowfield("snowfield");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genRivers(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = Rivers("rivers");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genSwamp(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = Swamp("swamp");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genConiferousForest(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = ConiferousForest("coniferousforest");
      res.add(place);
    }
    return res;
  }

  List<SubFrigidZonePlace> genTundra(SubFrigidZoneRoute route, int number) {
    final res = <SubFrigidZonePlace>[];
    for (var i = 0; i < number; i++) {
      final place = Tundra("tundra");
      res.add(place);
    }
    return res;
  }
}

List<SubFrigidZonePlace> _placesFromJson(dynamic json) => deserializeList<SubFrigidZonePlace>(json);

@JsonSerializable()
class SubFrigidZoneRoute extends RouteProtocol {
  @override
  @JsonKey()
  final String name;

  SubFrigidZoneRoute(this.name);

  @JsonKey(fromJson: _placesFromJson)
  List<SubFrigidZonePlace> places = [];

  int get placeCount => places.length;

  double routeProgress = 0.0; //勾股定理一下
  double getRouteProgress() => routeProgress; //

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

  //factory SubFrigidZoneRoute.fromJson(Map<String, dynamic> json) => //_$SubtropicsRouteFromJson(json);

  @override
  void onRestored() {
    for (final place in places) {
      place.route = this;
    }
  }

  @override
  PlaceProtocol get initialPlace => places[0]; //初始地点不要

  @override
  getRestoreIdOf(covariant PlaceProtocol place) {
    return places.indexOfAny(place);
  }

  //返回具体地点也需要2维图来

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

  static const type = "SubFrigidZoneRoute.SubFrigidZonePlace";

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

@JsonSerializable()
class IceSheet extends SubFrigidZonePlace {
  IceSheet(super.name);
}

@JsonSerializable()
class Snowfield extends SubFrigidZonePlace {
  Snowfield(super.name);
}

@JsonSerializable()
class Rivers extends SubFrigidZonePlace {
  Rivers(super.name);
}

@JsonSerializable()
class ConiferousForest extends SubFrigidZonePlace {
  ConiferousForest(super.name);
}

@JsonSerializable()
class BrownBearNest extends SubFrigidZonePlace {
  BrownBearNest(super.name);
}

@JsonSerializable()
class Tundra extends SubFrigidZonePlace {
  Tundra(super.name);
}

@JsonSerializable()
class Swamp extends SubFrigidZonePlace {
  Swamp(super.name);
}
