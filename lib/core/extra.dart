import 'package:json_annotation/json_annotation.dart';

mixin ExtraMixin {
  @JsonKey(includeIfNull: false)
  Map<String, dynamic>? extra;
}

extension ExtraX on ExtraMixin {
  dynamic operator [](String key) {
    return extra?[key];
  }

  void operator []=(String key, dynamic value) {
    (extra ??= {})[key] = value;
  }
}
