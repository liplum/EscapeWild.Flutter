import 'package:escape_wild/core/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usable.g.dart';

@JsonEnum()
enum UseType {
  use,
  drink,
  eat,
  equip;

  String l10nName() => I18n["use-type.$name"];
}

/// An [Item] can have multiple [UsableComp].
abstract class UsableComp extends ItemComp {
  /// The [compType] of subclass should be the same as [UsableComp].
  @override
  Type get compType => UsableComp;
  @JsonKey()
  final UseType useType;

  const UsableComp(this.useType);

  /// Whether player can use [stack].
  bool canUse(ItemStack stack) => true;

  /// When [stack] is used.
  Future<void> onUse(ItemStack stack) async {}

  static Iterable<UsableComp> of(ItemStack stack) => stack.meta.getCompsOf<UsableComp>();
}

@JsonSerializable(createToJson: false)
class ModifyAttrComp extends UsableComp {
  @JsonKey()
  final Iterable<AttrModifier> modifiers;
  @itemGetterJsonKey
  final ItemGetter? afterUsedItem;

  const ModifyAttrComp(
    super.useType,
    this.modifiers, {
    this.afterUsedItem,
  });

  bool get displayPreview => true;

  void buildAttrModification(ItemStack item, AttrModifierBuilder builder) {
    if (item.meta.mergeable) {
      for (final modifier in modifiers) {
        builder.add(modifier * item.massMultiplier);
      }
    } else {
      for (final modifier in modifiers) {
        builder.add(modifier);
      }
    }
  }

  @override
  Future<void> onUse(ItemStack stack) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(stack, builder);
    builder.performModification(player);
    final afterUsedItem = this.afterUsedItem;
    if (afterUsedItem != null) {
      final item = afterUsedItem();
      final entry = item.create();
      player.backpack.addItemOrMerge(entry);
    }
  }

  factory ModifyAttrComp.fromJson(Map<String, dynamic> json) => _$ModifyAttrCompFromJson(json);

  static const type = "AttrModify";

  @override
  String get typeName => type;
}

extension ModifyAttrCompX on Item {
  Item modifyAttr(
    UseType useType,
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      useType,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item asEatable(
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.eat,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item asUsable(
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.use,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item asDrinkable(
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      UseType.drink,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}
