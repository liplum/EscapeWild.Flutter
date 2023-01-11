import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

class Stuff {
  // fire related
  static late final Item plasticBottle, sticks, cutGrass, log, dryLichen, ember, tinder;
  static late final Item dandelion;
  static late final Item sharpStone;
  static late final Item can;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = Item.unmergeable("plastic-bottle", mass: 20).asFuel(heatValue: 5.0),
      sticks = Item.mergeable("sticks", mass: 100).asFuel(heatValue: 2.0),
      cutGrass = Item.mergeable("cut-grass", mass: 200).asFuel(heatValue: 4.5),
      log = Item.mergeable("log", mass: 500).asFuel(heatValue: 20.0),
      dryLichen = Item.mergeable("dry-lichen", mass: 10).asFuel(heatValue: 10.0),
      dandelion = Item.mergeable("dandelion", mass: 10),
      //It is said that dandelion boiled with water can relieve some constipation
      ember = Item.mergeable("ember", mass: 5),
      tinder = Item.mergeable("tinder", mass: 5),
      //Put the semi-wet moss or grass into the wooden tube rolled by the bark,
      // and Mars can carry it
      sharpStone = Item.mergeable("sharp-stone", mass: 100),
      ///////People's greatest wisdom comes from using tools
      can = Item.unmergeable("can", mass: 30),
    ]);
  }
}
