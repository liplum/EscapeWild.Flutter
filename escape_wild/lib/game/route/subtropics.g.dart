// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtropics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubtropicsLevel _$SubtropicsLevelFromJson(Map<String, dynamic> json) =>
    SubtropicsLevel()
      ..route = json['route'] == null
          ? null
          : SubtropicsRoute.fromJson(json['route'] as Map<String, dynamic>)
      ..routeSeed = json['routeSeed'] as int
      ..hardness = Contents.getHardnessByName(json['hardness'] as String);

Map<String, dynamic> _$SubtropicsLevelToJson(SubtropicsLevel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('route', instance.route);
  val['routeSeed'] = instance.routeSeed;
  val['hardness'] = Hardness.toName(instance.hardness);
  return val;
}

SubtropicsRoute _$SubtropicsRouteFromJson(Map<String, dynamic> json) =>
    SubtropicsRoute(
      json['name'] as String,
    )
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..places = _placesFromJson(json['places'])
      ..routeProgress = (json['routeProgress'] as num).toDouble();

Map<String, dynamic> _$SubtropicsRouteToJson(SubtropicsRoute instance) =>
    <String, dynamic>{
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'places': instance.places,
      'routeProgress': instance.routeProgress,
    };

SubtropicsPlace _$SubtropicsPlaceFromJson(Map<String, dynamic> json) =>
    SubtropicsPlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$SubtropicsPlaceToJson(SubtropicsPlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}

PlainPlace _$PlainPlaceFromJson(Map<String, dynamic> json) => PlainPlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$PlainPlaceToJson(PlainPlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}

ForestPlace _$ForestPlaceFromJson(Map<String, dynamic> json) => ForestPlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$ForestPlaceToJson(ForestPlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}

RiversidePlace _$RiversidePlaceFromJson(Map<String, dynamic> json) =>
    RiversidePlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$RiversidePlaceToJson(RiversidePlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}

CavePlace _$CavePlaceFromJson(Map<String, dynamic> json) => CavePlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$CavePlaceToJson(CavePlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}

HutPlace _$HutPlaceFromJson(Map<String, dynamic> json) => HutPlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$HutPlaceToJson(HutPlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}

VillagePlace _$VillagePlaceFromJson(Map<String, dynamic> json) => VillagePlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..fireState =
          FireState.fromJson(json['fireState'] as Map<String, dynamic>)
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$VillagePlaceToJson(VillagePlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['fireState'] = instance.fireState;
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}
