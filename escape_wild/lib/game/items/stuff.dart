import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/ecs.dart';
import 'package:escape_wild/core/item.dart';

class Stuff {
  Stuff._();

  // fire related
  static late final Item sticks, cutGrass, log, ember, tinder;
  static late final Item flower, pineNeedle;
  static late final Item strawRope;

  // stone
  static late final Item stone, sharpStone;

  // container
  static late final Item can, battleBottle, plasticBottle, woodenBowl;

  static void registerAll() {
    Contents.items.addAll([
      sticks = Item.mergeable("sticks", mass: 100).asFuel(heatValue: 10.0).tagged(["wooden", "sticks"]),
      cutGrass = Item.mergeable("cut-grass", mass: 200).asFuel(heatValue: 80.0).tagged(["straw", "flammable-floc"]),
      log = Item.mergeable("log", mass: 500).asFuel(heatValue: 200.0).tagged(["wooden", "log"]),
      flower = Item.mergeable("dandelion", mass: 10),
      pineNeedle = Item.mergeable("pine-needle", mass: 50).asFuel(heatValue: 10.0).tagged(["flammable-floc"]),
      //It is said that dandelion boiled with water can relieve some constipation
      // Ember will reduce durability over time.
      ember = Item.mergeable("ember", mass: 5).asFuel(heatValue: 20.0).hasDurability(max: 100),
      tinder = Item.mergeable("tinder", mass: 5).asFuel(heatValue: 15.0).tagged(["tinder"]),
      //Put the semi-wet moss or grass into the wooden tube rolled by the bark,
      // and Mars can carry it
      stone = Item.mergeable("stone", mass: 200).tagged(["stone"]),
      sharpStone = Item.mergeable("sharp-stone", mass: 200).tagged(["stone"]),
    ]);
    // craft
    Contents.items.addAll([
      strawRope = Item.mergeable("straw-rope", mass: 200).asFuel(heatValue: 100.0).tagged(["rope"]),
    ]);
    // container
    Contents.items.addAll([
      plasticBottle = Item.container(
        "plastic-bottle",
        mass: 10,
        acceptTags: ["liquid"],
        capacity: 500,
      ).asFuel(heatValue: 20.0).tagged(["plastic", "bottle"]),
      can = Item.container(
        "can",
        mass: 30,
        acceptTags: ["liquid"],
        capacity: 355,
      ).tagged(["metal", "can"]),
      battleBottle = Item.container(
        "battle-bottle",
        mass: 1150,
        acceptTags: ["liquid"],
        capacity: 2000,
      ).tagged(["metal", "bottle"]),
      woodenBowl = Item.container(
        "wooden-bowl",
        mass: 200,
        acceptTags: ["liquid"],
      ).asFuel(heatValue: 60.0).hasDurability(max: 100).tagged(["wooden", "bowl"]),
    ]);
  }
}
