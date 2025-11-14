// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtropics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubtropicsLevel _$SubtropicsLevelFromJson(Map<String, dynamic> json) => SubtropicsLevel()
  ..route = json['route'] == null ? null : SubtropicsRoute.fromJson(json['route'] as Map<String, dynamic>)
  ..routeSeed = (json['routeSeed'] as num).toInt()
  ..hardness = Contents.getHardnessByName(json['hardness'] as String);

Map<String, dynamic> _$SubtropicsLevelToJson(SubtropicsLevel instance) => <String, dynamic>{
  'route': ?instance.route,
  'routeSeed': instance.routeSeed,
  'hardness': Hardness.toName(instance.hardness),
};

SubtropicsRoute _$SubtropicsRouteFromJson(Map<String, dynamic> json) => SubtropicsRoute(json['name'] as String)
  ..places = _placesFromJson(json['places'])
  ..routeProgress = (json['routeProgress'] as num).toDouble();

Map<String, dynamic> _$SubtropicsRouteToJson(SubtropicsRoute instance) => <String, dynamic>{
  'name': instance.name,
  'places': instance.places,
  'routeProgress': instance.routeProgress,
};

SubtropicsPlace _$SubtropicsPlaceFromJson(Map<String, dynamic> json) => SubtropicsPlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$SubtropicsPlaceToJson(SubtropicsPlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};

PlainPlace _$PlainPlaceFromJson(Map<String, dynamic> json) => PlainPlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$PlainPlaceToJson(PlainPlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};

ForestPlace _$ForestPlaceFromJson(Map<String, dynamic> json) => ForestPlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$ForestPlaceToJson(ForestPlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};

RiversidePlace _$RiversidePlaceFromJson(Map<String, dynamic> json) => RiversidePlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$RiversidePlaceToJson(RiversidePlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};

CavePlace _$CavePlaceFromJson(Map<String, dynamic> json) => CavePlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$CavePlaceToJson(CavePlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};

HutPlace _$HutPlaceFromJson(Map<String, dynamic> json) => HutPlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$HutPlaceToJson(HutPlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};

VillagePlace _$VillagePlaceFromJson(Map<String, dynamic> json) => VillagePlace(json['name'] as String)
  ..extra = json['extra'] as Map<String, dynamic>?
  ..cookingTime = CampfireCookingMixin.tsFromJson(json['cookingTime'])
  ..onCampfire = CampfireCookingMixin.campfireStackFromJson(json['onCampfire'])
  ..offCampfire = CampfireCookingMixin.campfireStackFromJson(json['offCampfire'])
  ..recipe = Contents.getCookRecipesByName(json['recipe'] as String?)
  ..fireState = CampfireCookingMixin.fireStateFromJson(json['fireState'])
  ..exploreCount = (json['ec'] as num).toInt();

Map<String, dynamic> _$VillagePlaceToJson(VillagePlace instance) => <String, dynamic>{
  'extra': ?instance.extra,
  'cookingTime': ?CampfireCookingMixin.tsToJson(instance.cookingTime),
  'onCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.onCampfire),
  'offCampfire': ?CampfireCookingMixin.campfireStackToJson(instance.offCampfire),
  'recipe': ?CookRecipeProtocol.getNameOrNull(instance.recipe),
  'fireState': ?CampfireCookingMixin.fireStateStackToJson(instance.fireState),
  'name': instance.name,
  'ec': instance.exploreCount,
};
