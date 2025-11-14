import 'package:escape_wild/core/index.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instant.g.dart';

/// [InstantConvertCookRecipe] will transform an [Item] to another one instantly.
///
/// It doesn't allow [Item.container].
@JsonSerializable(createToJson: false)
class InstantConvertCookRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  /// the item as input
  @itemGetterJsonKey
  final ItemGetter input;

  /// If [input] is mergeable, cooking will consume [inputMass] amount of [input].
  final int? inputMass;

  /// the item as output
  @itemGetterJsonKey
  final ItemGetter output;

  /// If [output] is mergeable, cooking will create [outputMass] amount of [output].
  final int? outputMass;
  static const Set<ItemProp> kKeptProps = {
    .mass,
    .wetness,
    .durability,
    .freshness,
  };
  @JsonKey()
  final Set<ItemProp> keptProps;

  InstantConvertCookRecipe(
    super.name, {
    required this.input,
    required this.output,
    this.keptProps = InstantConvertCookRecipe.kKeptProps,
    this.inputMass,
    this.outputMass,
  });

  @override
  bool match(List<ItemStack> inputs) {
    if (inputs.length != 1) return false;
    final meta = inputs.first.meta;
    if (meta.isContainer) return false;
    return meta == input();
  }

  @override
  bool onMatch(List<ItemStack> inputs, List<ItemStack> outputs) {
    if (inputs.length != 1) return false;
    final input = inputs.first;
    if (input.meta != this.input()) return false;
    // handle input
    int? outputMass = this.outputMass;
    if (input.meta.mergeable) {
      int? inputMass = this.inputMass;
      assert(inputMass != null, "${input.meta} is mergeable but [inputMass] is not specified.");
      if (inputMass == null) {
        // if [inputMass] is empty, clear the input.
        inputs.clear();
      } else {
        input.mass = input.stackMass - inputMass;
        if (keptProps.contains(ItemProp.mass)) {
          // when [ItemProp.mass] is kept
          inputMass = input.stackMass;
        }
      }
    } else {
      inputs.clear();
    }
    // handle output
    final outputStack = output().create(mass: outputMass);
    _bakeOutput(input, outputStack);
    outputs.addItemOrMerge(outputStack);
    return true;
  }

  void _bakeOutput(ItemStack input, ItemStack output) {
    for (final prop in keptProps) {
      switch (prop) {
        case .wetness:
          final inputComp = WetnessComp.of(input);
          final outputComp = WetnessComp.of(output);
          if (inputComp != null && outputComp != null) {
            outputComp.setWetness(output, inputComp.getWetness(input));
          }
          break;
        case .durability:
          final inputComp = DurabilityComp.of(input);
          final outputComp = DurabilityComp.of(output);
          if (inputComp != null && outputComp != null) {
            outputComp.setDurability(output, inputComp.getDurability(input));
          }
          break;
        case .freshness:
          final inputComp = FreshnessComp.of(input);
          final outputComp = FreshnessComp.of(output);
          if (inputComp != null && outputComp != null) {
            outputComp.setFreshness(output, inputComp.getFreshness(input));
          }
          break;
        default:
      }
    }
  }

  factory InstantConvertCookRecipe.fromJson(Map<String, dynamic> json) => _$InstantConvertCookRecipeFromJson(json);

  static const type = "InstantConvertCookRecipe";

  @override
  String get typeName => type;
}
