import 'dart:math';

import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

typedef ItemGetter<T extends Item> = T Function();

class NamedItemGetter<T extends Item> {
  final String name;

  const NamedItemGetter(this.name);

  static ItemGetter<T> create<T extends Item>(String name) => NamedItemGetter(name).get as ItemGetter<T>;

  T get() => Contents.getItemMetaByName(name) as T;
}

extension NamedItemGetterX on String {
  ItemGetter<T> getAsItem<T extends Item>() => NamedItemGetter.create<T>(this);
}

/// ## When [mergeable] is false
/// It means the item is unmergeable, and [mass] is for one ItemStack.
/// ### Example
/// [mass] of `Tinned Tomatoes` is 500. So each ItemStack takes 500g room in backpack.
/// When player eat or cook it, if possible, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply full changes.
///
/// ## When [mergeable] is true
/// It means the item is mergeable, and [mass] is the unit for each ItemStack.
/// ### Example
/// [mass] of `Berry` is 10. However, ItemStack doesn't care that, it could have an independent [ItemStack.mass] instead.
/// When player eat or cook it, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply changes based [ItemStack.mass].
/// If [ItemStack.mass] is 25, and player has eaten 15g, then [ModifyAttrComp.modifiers] will apply `(15.0 / 10.0) * modifier`.
///
/// ## When [isContainer] is true
/// It means the item is a container, and [mass] stands for the weight of container itself.
///
class Item with Moddable, TagsMixin, CompMixin<ItemComp> {
  static final empty = Item("empty", mergeable: true, mass: 0);
  @override
  final String name;

  /// Unit: [g] gram.
  ///
  /// [mass] > 0
  final int mass;
  final bool mergeable;

  /// If this item [isContainer], it must not be [mergeable].
  bool get isContainer => containerComp != null;

  /// How much can this container hold.
  ContainerCompProtocol? containerComp;

  Item(
    this.name, {
    required this.mergeable,
    required this.mass,
  }) {
    assert(mergeable != isContainer, "`mergeable` and `isContainer` are conflict.");
  }

  Item.unmergeable(
    this.name, {
    required this.mass,
  })  : mergeable = false,
        assert(mass > 0);

  Item.mergeable(
    this.name, {
    required this.mass,
  }) : mergeable = true;

  Item.container(
    this.name, {
    required this.mass,
    Iterable<String>? acceptTags,
    int? capacity,
    bool? mergeablity,
  }) : mergeable = false {
    final comp = ContainerComp(
      acceptTags: acceptTags,
      capacity: capacity,
      mergeablity: mergeablity,
    );
    comp.validateItemConfig(this);
    containerComp = comp;
  }

  Item self() => this;

  String l10nName() => i18n("item.$name.name");

  String l10nDescription() => i18n("item.$name.desc");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Item || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

extension ItemX on Item {
  ItemStack create({int? mass, double? massF}) {
    if (mergeable) {
      if (mass != null) {
        return ItemStack(this, mass: mass);
      }
      if (massF != null) {
        return ItemStack(this, mass: (this.mass * massF).toInt());
      }
      // If the `ItemStack.mass` is not specified, use `Item.mass`.
      return ItemStack(this, mass: this.mass);
    } else {
      assert(mass == null && massF == null, "`mass` and `massFactor` should be both null for unmergeable");
      return ItemStack(this);
    }
  }

  List<ItemStack> repeat(int number) {
    assert(number > 0, "`number` should be over than 0.");
    assert(!mergeable, "only unmergeable can be generated repeatedly, but $name is given.");
    if (mergeable) {
      // For mergeable, it will multiply the mass.
      return [ItemStack(this, mass: mass * number)];
    } else {
      return List.generate(number.abs(), (i) => ItemStack(this));
    }
  }
}

/// [ContainerCompProtocol] is a special component.
///
/// [Item] can have ot most one [ContainerCompProtocol].
/// If so, the item becomes a container, and its associated [ItemStack] is [ContainerItemStack].
///
/// Nested container is forbidden.
abstract class ContainerCompProtocol {
  const ContainerCompProtocol();

  void validateItemConfig(Item item) {}

  /// Return whether [container] maybe accept [outer].
  ///
  /// The implementation should take those into account:
  /// - Whether [container] is too full to hold more.
  /// - Whether [container] has a different type of inner other than [outer]'s
  /// - Whether [outer] is another container.
  /// - And more...
  bool checkPossibleAccept(ContainerItemStack container, ItemStack outer);

  /// Return the part of [outer] that [container] is accepted.
  /// - [ItemStack] should be checked before in [checkPossibleAccept] and prepare to be split.
  /// - [ItemStack.empty] will be returned if [container] doesn't accept [outer] at all.
  /// - If [container] accepts [outer], [outer.stackMass] will be decreased.
  ItemStack splitAcceptedPart(ContainerItemStack container, ItemStack outer);

  /// When [container] accepts [outer].
  ///
  /// The implementation should handle something like blow:
  /// - Increment [container.innerMass].
  /// - Merge all components
  /// - And more...
  void onAccept(ContainerItemStack container, ItemStack outer);
}

class ContainerComp extends ContainerCompProtocol {
  /// - If [acceptTags] is not null, container will only allow item which matches all tags.
  final Iterable<String>? acceptTags;

  /// - If [capacity] is null, how much item container can hold is unlimited.
  /// - Otherwise, the [ContainerItemStack.innerMass] can't exceed it.
  final int? capacity;

  /// If [mergeablity] is not null, the [Item.mergeable] must match it.
  /// - When [mergeablity] is false, topping up is disallowed.
  ///   In other words, the whole container will be exclusive until [ContainerItemStack.inner] is empty.
  /// - When [mergeablity] is true, topping up is allowed, but the overflowing part will be ignored.
  final bool? mergeablity;

  const ContainerComp({
    this.acceptTags,
    this.capacity,
    this.mergeablity,
  });

  const ContainerComp.limitCapacity(
    this.capacity,
    this.mergeablity,
  ) : acceptTags = null;

  const ContainerComp.limitTags(
    this.acceptTags,
    this.mergeablity,
  ) : capacity = null;

  const ContainerComp.unlimited() : this();

  @override
  bool checkPossibleAccept(ContainerItemStack container, ItemStack outer) {
    if (outer.meta.isContainer) return false;
    final inner = container.inner;
    if (inner == null) {
      // container is empty
      // check if outer meets each condition
      if (mergeablity != null && mergeablity != outer.meta.mergeable) return false;
      final acceptTags = this.acceptTags;
      if (acceptTags != null && !outer.meta.hasTags(acceptTags)) return false;
      final capacity = this.capacity;
      if (capacity != null && capacity < outer.stackMass) return false;
    } else {
      // container has item
      // only allow mergeable
      if (!outer.meta.mergeable) return false;
      // only accept the same item
      if (!inner.hasIdenticalMeta(outer)) return false;
      // check if outer meets each condition
      if (mergeablity != null && mergeablity != outer.meta.mergeable) return false;
      final acceptTags = this.acceptTags;
      if (acceptTags != null && !outer.meta.hasTags(acceptTags)) return false;
      // check overflowing
      final capacity = this.capacity;
      if (capacity != null) {
        // container is full
        if (container.innerMass >= capacity) return false;
        // otherwise, container has some room for [outer]
      }
    }
    // Pass all tests!
    return true;
  }

  @override
  ItemStack splitAcceptedPart(ContainerItemStack container, ItemStack outer) {
    final capacity = this.capacity;
    var acceptedMass = outer.stackMass;
    if (capacity != null) {
      final containerRemainingRoom = min(0, capacity - container.innerMass);
      acceptedMass = min(outer.stackMass, containerRemainingRoom);
    }
    final part = outer.split(acceptedMass);
    return part;
  }

  @override
  void onAccept(ContainerItemStack container, ItemStack outer) {
    final inner = container.inner;
    if (inner == null) {
      container.inner = outer;
    } else {
      outer.mergeTo(inner);
    }
  }

  @override
  void validateItemConfig(Item item) {
    final mergeablity = this.mergeablity;
    if (mergeablity != null && mergeablity != item.mergeable) {
      throw ItemMergeableCompConflictError(
        "ContainerComp's mergeablity is not null but different from [item.mergeable].",
        item,
        mergeableShouldBe: mergeablity,
      );
    }
    // The [item.tags] might be not yet initialized, so ignore it.
  }
}

extension ContainerCompX on Item {
  Item asContainer({
    Iterable<String>? acceptTags,
    int? capacity,
    bool? mergeablity,
  }) {
    final comp = ContainerComp(
      acceptTags: acceptTags,
      capacity: capacity,
      mergeablity: mergeablity,
    );
    comp.validateItemConfig(this);
    containerComp = comp;
    return this;
  }
}

class ItemMergeableCompConflictError implements Exception {
  final String message;
  final Item item;
  final bool mergeableShouldBe;

  const ItemMergeableCompConflictError(
    this.message,
    this.item, {
    required this.mergeableShouldBe,
  });

  @override
  String toString() => "[${item.name}]$message. [Item.mergeable] should be $mergeableShouldBe.";
}

class ItemCompConflictError implements Exception {
  final String message;
  final Item item;

  const ItemCompConflictError(this.message, this.item);
}

abstract class ItemComp extends Comp {
  const ItemComp();

  void validateItemConfig(Item item) {}

  /// ## preconditions:
  /// - The [ItemStack.mass] of [from] and [to] are not changed.
  /// ## contrarians:
  /// - Implementation mustn't change [ItemStack.mass].
  void onMerge(ItemStack from, ItemStack to) {}

  /// ## preconditions:
  /// - The [ItemStack.mass] of [from] and [to] are not changed.
  /// - [to] has an [Item.extra] clone from [from].
  /// ## contrarians:
  /// - Implementation mustn't change [ItemStack.mass].
  void onSplit(ItemStack from, ItemStack to) {}

  Future<void> onPass(ItemStack stack, TS delta) async {}
}

class ItemCompPair<T extends Comp> {
  final ItemStack item;
  final T comp;

  const ItemCompPair(this.item, this.comp);
}

@JsonSerializable()
class ItemStack with ExtraMixin implements JConvertibleProtocol {
  static final empty = ItemStack(Item.empty);
  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: _getItemMetaName)
  final Item meta;

  @JsonKey(includeIfNull: false)
  int? mass;

  int get stackMass => mass ?? meta.mass;

  ItemStack(
    this.meta, {
    this.mass,
  });

  String displayName() => meta.l10nName();

  bool hasIdenticalMeta(ItemStack other) => meta == other.meta;

  bool conformTo(Item meta) => this.meta == meta;

  bool get canSplit => meta.mergeable;

  bool get canMerge => meta.mergeable;

  bool get isEmpty => identical(this, empty) || meta == Item.empty || stackMass <= 0;

  @override
  String toString() {
    final m = mass;
    final name = meta.l10nName();
    if (m == null) {
      return name;
    } else {
      return "$name ${m.toStringAsFixed(1)}g";
    }
  }

  /// Merge this to [target].
  /// - [target.stackMass] will be increased.
  /// - This [stackMass] will be clear.
  ///
  /// Please call [Backpack.addItemOrMerge] to track changes, such as [Backpack.mass].
  void mergeTo(ItemStack target) {
    assert(meta.mergeable, "${meta.name} is not mergeable.");
    if (!meta.mergeable) return;
    assert(hasIdenticalMeta(target), "Can't merge ${meta.name} with ${target.meta.name}.");
    if (!hasIdenticalMeta(target)) return;
    final selfMass = stackMass;
    final toMass = target.stackMass;
    // handle components
    for (final comp in meta.iterateComps()) {
      comp.onMerge(this, target);
    }
    target.mass = selfMass + toMass;
    mass = 0;
  }

  /// Split a part of this, and return the part.
  /// - This [stackMass] will be decreased.
  ///
  /// Please call [Backpack.splitItemInBackpack] to track changes, such as [Backpack.mass].
  /// ```dart
  /// if(canSplit)
  ///   mass = actualMass - massOfPart;
  /// ```
  ItemStack split(int massOfPart) {
    assert(massOfPart > 0, "`mass` to split must be more than 0");
    if (massOfPart <= 0) return empty;
    assert(stackMass >= massOfPart, "Self `mass` must be more than `mass` to split.");
    if (stackMass < massOfPart) return empty;
    assert(canSplit, "${meta.name} can't be split.");
    if (!canSplit) return empty;
    final selfMass = stackMass;
    // if self mass is less than or equal to mass to split, return a clone.
    if (selfMass <= massOfPart) return clone();
    final part = ItemStack(meta, mass: massOfPart);
    // clone extra
    part.extra = cloneExtra();
    // handle components
    for (final comp in meta.iterateComps()) {
      comp.onSplit(this, part);
    }
    mass = selfMass - massOfPart;
    return part;
  }

  Future<void> onPass(TS delta) async {
    for (final comp in meta.iterateComps()) {
      await comp.onPass(this, delta);
    }
  }

  factory ItemStack.fromJson(Map<String, dynamic> json) => _$ItemStackFromJson(json);

  Map<String, dynamic> toJson() => _$ItemStackToJson(this);

  ItemStack clone() {
    final cloned = ItemStack(meta, mass: mass);
    cloned.extra = cloneExtra();
    return cloned;
  }

  static const type = "ItemStack";

  @override
  String get typeName => type;
}

@JsonSerializable()
class ContainerItemStack extends ItemStack {
  @JsonKey(includeIfNull: false)
  ItemStack? inner;

  @override
  set mass(int? newMass) {
    assert(false, "ContainerItemStack's mass can't be changed.");
  }

  /// [stackMass] is the sum of container and [inner].
  @override
  int get stackMass => innerMass + meta.mass;

  int get innerMass => inner?.stackMass ?? 0;

  ContainerItemStack(super.meta) {
    assert(meta.isContainer, "ContainerItemStack requires [item] to be a container.");
  }

  bool get containsItem => inner?.isNotEmpty != true;

  @override
  String displayName() {
    final inner = this.inner;
    if (inner == null) {
      return meta.l10nName();
    } else {
      return "${meta.l10nName()}[${inner.displayName()}]";
    }
  }

  /// The container itself can't be merged.
  @override
  bool get canMerge => false;

  /// The container itself can't be split.
  @override
  bool get canSplit => false;

  /// The container itself can't be merge.
  @override
  void mergeTo(ItemStack to) {}

  /// The container itself can't be split.
  @override
  ItemStack split(int massOfPart) {
    return this;
  }

  factory ContainerItemStack.fromJson(Map<String, dynamic> json) => _$ContainerItemStackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContainerItemStackToJson(this);

  static const type = "ContainerItemStack";

  @override
  String get typeName => type;
}

extension ItemStackX on ItemStack {
  /// [massMultiplier] is always 1.0 when [Item.mergeable] is true.
  double get massMultiplier => meta.mergeable ? stackMass / meta.mass : 1.0;

  bool canMergeTo(ItemStack to) {
    return hasIdenticalMeta(to) && meta.mergeable;
  }

  bool get isNotEmpty => !isEmpty;
}

extension ItemStackListX on List<ItemStack> {
  ItemStack? findFirstByName(String name) {
    for (final item in this) {
      if (item.meta.name == name) {
        return item;
      }
    }
    return null;
  }

  ItemStack? findFirstByTag(String tag) {
    for (final item in this) {
      if (item.meta.hasTag(tag)) {
        return item;
      }
    }
    return null;
  }

  ItemStack? findFirstByTags(Iterable<String> tags) {
    for (final item in this) {
      if (item.meta.hasTags(tags)) {
        return item;
      }
    }
    return null;
  }

  Iterable<ItemStack> findAllByTag(String tag) sync* {
    for (final item in this) {
      if (item.meta.hasTag(tag)) {
        yield item;
      }
    }
  }

  Iterable<ItemStack> findAllByTags(Iterable<String> tags) sync* {
    for (final item in this) {
      if (item.meta.hasTags(tags)) {
        yield item;
      }
    }
  }

  void addItemOrMergeAll(List<ItemStack> additions) {
    for (final addition in additions) {
      addItemOrMerge(addition);
    }
  }

  void addItemOrMerge(ItemStack addition) {
    var merged = false;
    for (final result in this) {
      if (addition.canMergeTo(result)) {
        addition.mergeTo(result);
        merged = true;
        break;
      }
    }
    if (!merged) {
      add(addition);
    }
  }
}

typedef ItemTypeMatcher = bool Function(Item item);
typedef ItemStackMatcher = ItemStackMatchResult Function(ItemStack stack);

enum ItemStackMatchResult {
  matched,
  typeUnmatched,
  massUnmatched;

  bool get isMatched => this == matched;
}

class ItemMatcher {
  final ItemTypeMatcher typeOnly;
  final ItemStackMatcher exact;

  const ItemMatcher({
    required this.typeOnly,
    required this.exact,
  });

  static ItemMatcher hasTag(List<String> tags) => ItemMatcher(
        typeOnly: (item) => item.hasTags(tags),
        exact: (item) => item.meta.hasTags(tags) ? ItemStackMatchResult.matched : ItemStackMatchResult.typeUnmatched,
      );

  static ItemMatcher hasComp(List<Type> compTypes) => ItemMatcher(
        typeOnly: (item) => item.hasComps(compTypes),
        exact: (item) =>
            item.meta.hasComps(compTypes) ? ItemStackMatchResult.matched : ItemStackMatchResult.typeUnmatched,
      );
  static ItemMatcher any = ItemMatcher(typeOnly: (_) => true, exact: (_) => ItemStackMatchResult.matched);
}

extension ItemStackMatcherX on ItemStackMatcher {
  Matcher<ItemStack> get bool => (stack) => this(stack).isMatched;
}

extension ItemMatcherX on ItemMatcher {
  Iterable<Item> filterTypeMatchedItems(Iterable<Item> items, {bool requireMatched = true}) sync* {
    for (final item in items) {
      if (requireMatched) {
        if (typeOnly(item)) {
          yield item;
        }
      } else {
        if (!typeOnly(item)) {
          yield item;
        }
      }
    }
  }

  Iterable<ItemStack> filterExactMatchedStacks(Iterable<ItemStack> stacks, {bool requireMatched = true}) sync* {
    for (final stack in stacks) {
      if (requireMatched) {
        if (exact(stack).isMatched) {
          yield stack;
        }
      } else {
        if (!exact(stack).isMatched) {
          yield stack;
        }
      }
    }
  }

  Iterable<ItemStack> filterTypedMatchedStacks(Iterable<ItemStack> stacks, {bool requireMatched = true}) sync* {
    for (final stack in stacks) {
      if (requireMatched) {
        if (typeOnly(stack.meta)) {
          yield stack;
        }
      } else {
        if (!typeOnly(stack.meta)) {
          yield stack;
        }
      }
    }
  }
}

class EmptyComp extends Comp {
  static const type = "Empty";

  @override
  String get typeName => type;
}

String _getItemMetaName(Item meta) => meta.name;

class DurabilityComp extends ItemComp {
  static const _durabilityK = "Durability.durability";
  final double max;

  const DurabilityComp(this.max);

  double getDurability(ItemStack stack) => stack[_durabilityK] ?? max;

  bool isBroken(ItemStack stack) => getDurability(stack) <= 0.0;

  void setDurability(ItemStack stack, double value) => stack[_durabilityK] = value;

  Ratio durabilityRatio(ItemStack stack) {
    if (max < 0.0) return 1;
    return getDurability(stack) / max;
  }

  @override
  void onMerge(ItemStack from, ItemStack to) {
    if (!from.hasIdenticalMeta(to)) return;
    setDurability(to, getDurability(from) + getDurability(to));
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(DurabilityComp)) {
      throw ItemCompConflictError(
        "Only allow one $DurabilityComp.",
        item,
      );
    }
  }

  static DurabilityComp? of(ItemStack stack) => stack.meta.getFirstComp<DurabilityComp>();

  static double tryGetDurability(ItemStack stack) => of(stack)?.getDurability(stack) ?? 0.0;

  /// Default is false
  static bool tryGetIsBroken(ItemStack stack) => of(stack)?.isBroken(stack) ?? false;

  /// Default is 1.0
  static double tryGetDurabilityRatio(ItemStack stack) => of(stack)?.durabilityRatio(stack) ?? 1.0;

  static void trySetDurability(ItemStack stack, double durability) => of(stack)?.setDurability(stack, durability);
  static const type = "Durability";

  @override
  String get typeName => type;
}

extension DurabilityCompX on Item {
  Item hasDurability({
    required double max,
  }) {
    final comp = DurabilityComp(max);
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

@JsonSerializable(createToJson: false)
class ToolAttr implements Comparable<ToolAttr> {
  @JsonKey()
  final double efficiency;

  const ToolAttr({required this.efficiency});

  static const ToolAttr low = ToolAttr(
        efficiency: 0.6,
      ),
      normal = ToolAttr(
        efficiency: 1.0,
      ),
      high = ToolAttr(
        efficiency: 1.8,
      ),
      max = ToolAttr(
        efficiency: 2.0,
      );

  factory ToolAttr.fromJson(Map<String, dynamic> json) => _$ToolAttrFromJson(json);

  @override
  int compareTo(ToolAttr other) => efficiency.compareTo(other.efficiency);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ToolAttr || runtimeType != other.runtimeType) return false;
    return efficiency == other.efficiency;
  }

  @override
  int get hashCode => efficiency.hashCode;
}

class ToolType {
  final String name;

  const ToolType(this.name);

  factory ToolType.named(String name) => ToolType(name);

  static const ToolType cutting = ToolType("cutting");

  /// Use to cut down tree
  static const ToolType axe = ToolType("axe");

  /// Use to hunt
  static const ToolType trap = ToolType("trap");

  /// Use to hunt
  static const ToolType gun = ToolType("gun");

  /// Use to fish
  static const ToolType fishing = ToolType("fishing");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ToolType || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable(createToJson: false)
class ToolComp extends ItemComp {
  @JsonKey(fromJson: ToolAttr.fromJson)
  final ToolAttr attr;
  @JsonKey(fromJson: ToolType.named)
  final ToolType toolType;

  const ToolComp({
    this.attr = ToolAttr.normal,
    required this.toolType,
  });

  void damageTool(ItemStack item, double damage) {
    final durabilityComp = DurabilityComp.of(item);
    // the tool is unbreakable
    if (durabilityComp == null) return;
    final former = durabilityComp.getDurability(item);
    durabilityComp.setDurability(item, former - damage);
  }

  bool isBroken(ItemStack item) {
    return DurabilityComp.tryGetIsBroken(item);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$ToolComp doesn't conform to mergeable item.",
        item,
        mergeableShouldBe: false,
      );
    }
  }

  factory ToolComp.fromJson(Map<String, dynamic> json) => _$ToolCompFromJson(json);
  static const type = "Tool";

  @override
  String get typeName => type;
}

extension ToolCompX on Item {
  Item asTool({
    required ToolType type,
    ToolAttr attr = ToolAttr.normal,
  }) {
    final comp = ToolComp(
      attr: attr,
      toolType: type,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

@JsonEnum()
enum UseType {
  use,
  drink,
  eat,
  equip;

  String l10nName() => I18n["use-type.$name"];
}

abstract class UsableComp extends ItemComp {
  @JsonKey()
  final UseType useType;

  const UsableComp(this.useType);

  bool canUse() => true;

  Future<void> onUse(ItemStack item) async {}

  bool get displayPreview => true;
  static const type = "Usable";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ModifyAttrComp extends UsableComp {
  @override
  Type get compType => UsableComp;
  @JsonKey()
  final List<AttrModifier> modifiers;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item>? afterUsedItem;

  const ModifyAttrComp(
    super.useType,
    this.modifiers, {
    this.afterUsedItem,
  });

  factory ModifyAttrComp.fromJson(Map<String, dynamic> json) => _$ModifyAttrCompFromJson(json);

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
  Future<void> onUse(ItemStack item) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(item, builder);
    builder.performModification(player);
    final afterUsedItem = this.afterUsedItem;
    if (afterUsedItem != null) {
      final item = afterUsedItem();
      final entry = item.create();
      player.backpack.addItemOrMerge(entry);
    }
  }

  static const type = "AttrModify";

  @override
  String get typeName => type;
}

extension ModifyAttrCompX on Item {
  Item modifyAttr(
    UseType useType,
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      useType,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asEatable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.eat,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asUsable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.use,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asDrinkable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      UseType.drink,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

@JsonEnum()
enum CookType {
  cook,
  boil,
  roast;
}

/// Player can cook the CookableItem in campfire.
/// It will be transformed to another item.
@JsonSerializable(createToJson: false)
class CookableComp extends ItemComp {
  @JsonKey()
  final CookType cookType;
  @JsonKey()
  final double fuelCost;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> cookedOutput;

  const CookableComp(
    this.cookType,
    this.fuelCost,
    this.cookedOutput,
  );

  double getActualFuelCost(ItemStack raw) {
    if (raw.meta.mergeable) {
      return raw.massMultiplier * fuelCost;
    } else {
      return fuelCost;
    }
  }

  double getUnitFuelCostPerMass(ItemStack raw) {
    return fuelCost / raw.meta.mass;
  }

  int getMaxCookablePart(ItemStack raw, double totalFuel) {
    if (raw.meta.mergeable) {
      return totalFuel ~/ (fuelCost / raw.meta.mass);
    } else {
      return totalFuel >= fuelCost ? raw.stackMass : 0;
    }
  }

  ItemStack cook(ItemStack raw) {
    final cooked = cookedOutput();
    return cooked.create()..mass = (raw.massMultiplier * cooked.mass).toInt();
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(CookableComp)) {
      throw ItemCompConflictError(
        "Only allow one $CookableComp.",
        item,
      );
    }
  }

  static CookableComp? of(ItemStack stack) => stack.meta.getFirstComp<CookableComp>();

  static const type = "Cookable";

  @override
  String get typeName => type;

  factory CookableComp.fromJson(Map<String, dynamic> json) => _$CookableCompFromJson(json);
}

extension CookableCompX on Item {
  Item asCookable(
    CookType cookType, {
    required double fuelCost,
    required ItemGetter<Item> output,
  }) {
    final comp = CookableComp(
      cookType,
      fuelCost,
      output,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

@JsonSerializable(createToJson: false)
class FuelComp extends ItemComp {
  @JsonKey()
  final double heatValue;

  const FuelComp(this.heatValue);

  /// If the [stack] has [WetComp], reduce the [heatValue] based on its wet.
  double getActualHeatValue(ItemStack stack) {
    var res = heatValue * stack.massMultiplier;
    // check wet
    final wet = WetComp.tryGetWet(stack);
    res *= 1.0 - wet;
    // check durability
    final ratio = DurabilityComp.tryGetDurabilityRatio(stack);
    res *= ratio;
    return res;
  }

  static FuelComp? of(ItemStack stack) => stack.meta.getFirstComp<FuelComp>();

  static double tryGetHeatValue(ItemStack stack) => of(stack)?.getActualHeatValue(stack) ?? 0.0;
  static const type = "Fuel";

  @override
  String get typeName => type;

  factory FuelComp.fromJson(Map<String, dynamic> json) => _$FuelCompFromJson(json);
}

extension FuelCompX on Item {
  Item asFuel({
    required double heatValue,
  }) {
    final comp = FuelComp(
      heatValue,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

class WetComp extends ItemComp {
  static const _wetK = "Wet.wet";
  static const defaultWet = 0.0;
  static const defaultDryTime = TS(30);
  final TS dryTime;

  const WetComp({
    this.dryTime = defaultDryTime,
  });

  Ratio getWet(ItemStack item) => item[_wetK] ?? defaultWet;

  void setWet(ItemStack item, Ratio value) => item[_wetK] = value.clamp(0.0, 1.0);

  @override
  void onMerge(ItemStack from, ItemStack to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.stackMass;
    final toMass = to.stackMass;
    final fromWet = getWet(from) * fromMass;
    final toWet = getWet(to) * toMass;
    final merged = (fromWet + toWet) / (fromMass + toMass);
    setWet(to, merged);
  }

  @override
  Future<void> onPass(ItemStack stack, TS delta) async {
    final lost = delta / dryTime;
    final wet = getWet(stack);
    setWet(stack, wet - lost);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(WetComp)) {
      throw ItemCompConflictError(
        "Only allow one $WetComp.",
        item,
      );
    }
  }

  static WetComp? of(ItemStack stack) => stack.meta.getFirstComp<WetComp>();

  static double tryGetWet(ItemStack stack) => of(stack)?.getWet(stack) ?? defaultWet;

  static void trySetWet(ItemStack stack, double wet) => of(stack)?.setWet(stack, wet);
  static const type = "Wet";

  @override
  String get typeName => type;
}

extension WetCompX on Item {
  Item hasWet({
    TS dryTime = WetComp.defaultDryTime,
  }) {
    final comp = WetComp(
      dryTime: dryTime,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

class FreshnessComp extends ItemComp {
  static const _freshnessK = "Freshness.freshness";
  final TS expire;

  const FreshnessComp({
    required this.expire,
  });

  Ratio getFreshness(ItemStack item) => item[_freshnessK] ?? 1.0;

  void setFreshness(ItemStack item, Ratio value) => item[_freshnessK] = value.clamp(0.0, 1.0);

  @override
  void onMerge(ItemStack from, ItemStack to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.stackMass;
    final toMass = to.stackMass;
    final fromFreshness = getFreshness(from) * fromMass;
    final toFreshness = getFreshness(to) * toMass;
    final merged = (fromFreshness + toFreshness) / (fromMass + toMass);
    setFreshness(to, merged);
  }

  @override
  Future<void> onPass(ItemStack stack, TS delta) async {
    final lost = delta / expire;
    final freshness = getFreshness(stack);
    setFreshness(stack, freshness - lost);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(FreshnessComp)) {
      throw ItemCompConflictError(
        "Only allow one $FreshnessComp.",
        item,
      );
    }
  }

  static const type = "Freshness";

  @override
  String get typeName => type;
}

extension FreshnessCompX on Item {
  Item hasFreshness({
    required TS expire,
  }) {
    final comp = FreshnessComp(expire: expire);
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

class FireStarterComp extends ItemComp {
  final Ratio chance;
  final double cost;

  const FireStarterComp({
    required this.chance,
    required this.cost,
  });

  bool tryStartFire(ItemStack stack, [Random? rand]) {
    rand ??= Rand.backend;
    var chance = this.chance;
    // check wet
    final wet = WetComp.tryGetWet(stack);
    chance *= 1.0 - wet;
    final success = rand.one() <= chance;
    final durabilityComp = DurabilityComp.of(stack);
    if (durabilityComp != null) {
      final durability = durabilityComp.getDurability(stack);
      durabilityComp.setDurability(stack, durability - cost);
    }
    return success;
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$FireStarterComp doesn't conform to mergeable item.",
        item,
        mergeableShouldBe: false,
      );
    }
    if (item.hasComp(FireStarterComp)) {
      throw ItemCompConflictError(
        "Only allow one $FireStarterComp.",
        item,
      );
    }
  }

  static FireStarterComp? of(ItemStack stack) => stack.meta.getFirstComp<FireStarterComp>();

  static const type = "FireStarter";

  @override
  String get typeName => type;
}

extension FireStarterCompX on Item {
  Item asFireStarter({
    required Ratio chance,
    required double cost,
  }) {
    final comp = FireStarterComp(
      chance: chance,
      cost: cost,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}
