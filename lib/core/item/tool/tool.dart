import 'package:escape_wild/core/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tool.g.dart';

@JsonSerializable()
class ToolAttr implements Comparable<ToolAttr> {
  @JsonKey()
  final double efficiency;

  const ToolAttr({required this.efficiency});

  static const ToolAttr //
  low = .new(efficiency: 0.6),
      normal = .new(efficiency: 1.0),
      high = .new(efficiency: 1.8),
      max = .new(efficiency: 2.0);

  factory ToolAttr.fromJson(Map<String, dynamic> json) => _$ToolAttrFromJson(json);

  Map<String, dynamic> toJson() => _$ToolAttrToJson(this);

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

class ToolType with Moddable {
  @override
  final String name;

  ToolType(this.name);

  factory ToolType.fromJson(String name) => ToolType(name);

  String toJson() => name;
  static final ToolType //
      /// Use to cut materials
      cutting = .new(
        "cutting",
      ),
      /// Use to cut down tree
      axe = .new(
        "axe",
      ),
      /// Use to hunt
      trap = .new(
        "trap",
      ),
      /// Use to hunt
      gun = .new(
        "gun",
      ),
      /// Use to fish
      fishing = .new(
        "fishing",
      ),
      /// Use to light
      lighting = .new(
        "lighting",
      );

  String l10nName() => i18n("tool-type.$name");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ToolType || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// An [Item] can have at most one [ToolComp] for each different [ToolType].
@JsonSerializable(createToJson: false)
class ToolComp extends ItemComp {
  @JsonKey(fromJson: ToolAttr.fromJson)
  final ToolAttr attr;
  @JsonKey(fromJson: ToolType.fromJson)
  final ToolType toolType;

  const ToolComp({this.attr = .normal, required this.toolType});

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
    for (final comp in item.getCompsOf<ToolComp>()) {
      if (comp.toolType == toolType) {
        throw ItemCompConflictError("$ToolComp already exists for $toolType.", item);
      }
    }
  }

  static Iterable<ToolComp> of(ItemStack stack) => stack.meta.getCompsOf<ToolComp>();

  static ToolComp? ofType(ItemStack stack, ToolType toolType) {
    for (final comp in stack.meta.getCompsOf<ToolComp>()) {
      if (comp.toolType == toolType) {
        return comp;
      }
    }
    return null;
  }

  factory ToolComp.fromJson(Map<String, dynamic> json) => _$ToolCompFromJson(json);
  static const type = "Tool";

  @override
  String get typeName => type;
}

extension ToolCompX on Item {
  Item asTool({required ToolType type, ToolAttr attr = ToolAttr.normal}) {
    final comp = ToolComp(attr: attr, toolType: type);
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}
