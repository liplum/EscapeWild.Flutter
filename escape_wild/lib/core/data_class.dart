import 'package:escape_wild/core/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_class.g.dart';

@JsonSerializable(createToJson: false)
class TagMassEntry {
  @JsonKey()
  final Iterable<String> tags;
  @JsonKey()
  final int? mass;

  const TagMassEntry(this.tags, this.mass);

  /// ## Supported format:
  /// - original json object:
  /// ```json
  /// {
  ///   "tags":["raw","meat"],
  ///   "mass": 200
  /// }
  /// ```
  /// - String literal:
  /// ```json
  /// "raw,meat/200"
  /// ```
  factory TagMassEntry.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _$TagMassEntryFromJson(json);
    } else {
      final literal = json.toString();
      final tagsNMass = literal.split('/');
      final tags = tagsNMass[0].split(',');
      final mass = tagsNMass.length > 1 ? num.parse(tagsNMass[1]).toInt() : null;
      return TagMassEntry(tags, mass);
    }
  }

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
