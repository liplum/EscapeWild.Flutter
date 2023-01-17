import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable(createToJson: false)
class TagMassEntry {
  @JsonKey()
  final Iterable<String> tags;
  @JsonKey()
  final int? mass;

  const TagMassEntry(this.tags, this.mass);

  factory TagMassEntry.fromJson(Map<String, dynamic> json) => _$TagMassEntryFromJson(json);

  @override
  String toString() {
    final mass = this.mass;
    final tagsStr = tags.join(", ");
    return mass == null ? tagsStr : "$tagsStr ${mass}g";
  }
}

@JsonSerializable(createToJson: false)
class LazyItemStack {
  @itemGetterJsonKey
  final ItemGetter item;
  @JsonKey()
  final int? mass;

  const LazyItemStack(this.item, this.mass);

  factory LazyItemStack.fromJson(Map<String, dynamic> json) => _$LazyItemStackFromJson(json);
}

extension TagMassEntryLazyItemStackIntX on int {
  TagMassEntry tag(dynamic tags) {
    if (tags is List) {
      return TagMassEntry(tags.map((tag) => tag.toString()).toList(), this);
    } else {
      return TagMassEntry([tags.toString()], this);
    }
  }

  LazyItemStack stack(ItemGetter get) => LazyItemStack(get, this);
}
