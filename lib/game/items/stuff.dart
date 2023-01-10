import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/item.dart';

class Stuff {
  static late Item plasticBottle,
      sticks,
      cutGrass,
      log,
      dryLichen,
      dandelion,
      saveKindlingCartridge,
      sharpStone,
      wasteEmptyCans;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = Item("plastic-bottle").asFuel(heatValue: 5.0),
      sticks = Item("sticks").asFuel(heatValue: 2.0),
      cutGrass = Item("cut-grass").asFuel(heatValue: 5.0),
      log = Item("log").asFuel(heatValue: 20.0),
      dryLichen = Item("dry-lichen").asFuel(heatValue: 10.0),
      dandelion = Item("dandelion"),
      //It is said that dandelion boiled with water can relieve some constipation
      saveKindlingCartridge = Item("save-kindling-cartridge"),
      //Put the semi-wet moss or grass into the wooden tube rolled by the bark,
      // and Mars can carry it
      sharpStone = Item("sharp-stone"),
      ///////People's greatest wisdom comes from using tools
      wasteEmptyCans = Item("waste-empty-cans"),

    ]);
  }
}
