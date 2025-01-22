import 'package:escape_wild/core/index.dart';
import 'package:jconverter/jconverter.dart';

void registerTypes(JConverter cvt) {
  cvt.addAuto(ItemStack.type, ItemStack.fromJson);
  cvt.addAuto(ContainerItemStack.type, ContainerItemStack.fromJson);
  cvt.addAuto(Backpack.type, Backpack.fromJson);
}
