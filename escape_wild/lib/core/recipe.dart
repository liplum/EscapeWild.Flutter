import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable()
class TagMassEntry {
  @JsonKey()
  final String tag;
  @JsonKey()
  final int? mass;

  const TagMassEntry(this.tag, this.mass);

  factory TagMassEntry.fromJson(Map<String, dynamic> json) => _$TagMassEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TagMassEntryToJson(this);

  @override
  String toString() {
    final mass = this.mass;
    return mass == null ? tag : "$tag ${mass}g";
  }
}
