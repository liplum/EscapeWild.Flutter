import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';

/// [ContainerCookRecipe] will transform a certain [Item] that meets [inputTags] into [result] by a certain ratio.
/// It only allow one input.
///
/// For example,
class ContainerCookRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  final List<String> inputTags;
  final ItemGetter result;

  ContainerCookRecipe(super.name, this.inputTags, this.result);

  @override
  bool match(List<ItemStack> inputs) {
    throw UnimplementedError();
  }

  @override
  bool updateCooking(
    List<ItemStack> inputs,
    List<ItemStack> outputs,
    Ts totalTimePassed,
    Ts delta,
  ) {
    throw UnimplementedError();
  }

  static const type = "ContainerCookRecipe";

  @override
  String get typeName => type;
}
