import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/ecs.dart';
import 'package:escape_wild/core/item.dart';

class Stuff {
  Stuff._();

  // fire related
  static late final Item plasticBottle, sticks, cutGrass, log, ember, tinder;
  static late final Item flower, pineNeedle;
  static late final Item strawRope;

  // stone
  static late final Item stone, sharpStone;
  static late final Item can;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = Item.unmergeable("plastic-bottle", mass: 20).asFuel(heatValue: 5.0).tagged(["plastic", "bottle"]),
      sticks = Item.mergeable("sticks", mass: 100).asFuel(heatValue: 2.0).tagged(["wooden", "sticks"]),
      cutGrass = Item.mergeable("cut-grass", mass: 200).asFuel(heatValue: 4.5).tagged(["straw", "flammable-floc"]),
      log = Item.mergeable("log", mass: 500).asFuel(heatValue: 20.0).tagged(["wooden", "log"]),
      flower = Item.mergeable("dandelion", mass: 10),
      pineNeedle = Item.mergeable("pine-needle", mass: 50).asFuel(heatValue: 5.0).tagged(["flammable-floc"]),
      //It is said that dandelion boiled with water can relieve some constipation
      ember = Item.mergeable("ember", mass: 5),
      tinder = Item.mergeable("tinder", mass: 5).tagged(["tinder"]),
      //Put the semi-wet moss or grass into the wooden tube rolled by the bark,
      // and Mars can carry it
      stone = Item.mergeable("stone", mass: 100).tagged(["stone"]),
      sharpStone = Item.mergeable("sharp-stone", mass: 100).tagged(["stone"]),
      ///////People's greatest wisdom comes from using tools
      can = Item.unmergeable("can", mass: 30).tagged(["metal", "can"]),
    ]);
    // Craft
    Contents.items.addAll([
      strawRope = Item.unmergeable("straw-rope", mass: 200),
    ]);
  }
}
