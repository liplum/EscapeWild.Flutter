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

  Map<String, dynamic>? cloneExtra() {
    final mine = extra;
    if (mine == null) return null;
    final res = <String, dynamic>{};
    for (final p in mine.entries) {
      var v = p.value;
      if (v is! int && v is! String && v is! double && v is! bool) {
        // if it's a map, deep clone it
        if (v is Map) {
          v = _deepCloneMapValues(v);
          // if it's a list, deep clone it
        } else if (v is List) {
          v = _deepCloneListElements(v);
        } else {
          // If its type is not supported by json, try to invoke `clone()`.
          try {
            v = v.clone();
          } catch (_) {}
        }
      }
      res[p.key] = v;
    }
    return res;
  }
}

Map<dynamic, dynamic> _deepCloneMapValues(Map<dynamic, dynamic> map) {
  final cloned = <dynamic, dynamic>{};
  for (final p in map.entries) {
    var v = p.value;
    if (v is Map) {
      v = _deepCloneMapValues(v);
    } else if (v is List) {
      v = _deepCloneListElements(v);
    }
    cloned[p] = v;
  }
  return cloned;
}

List<dynamic> _deepCloneListElements(List<dynamic> list) {
  final cloned = <dynamic>[];
  for (var e in list) {
    if (e is Map) {
      e = _deepCloneMapValues(e);
    } else if (e is List) {
      e = _deepCloneListElements(e);
    }
    cloned.add(e);
  }
  return cloned;
}
