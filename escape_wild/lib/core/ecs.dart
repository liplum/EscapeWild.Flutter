import 'package:collection/collection.dart';
import 'package:jconverter/jconverter.dart';
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

mixin TagsMixin {
  @JsonKey(includeIfNull: false)
  final Set<String> tags = {};
}

extension TagsMixinX<T extends TagsMixin> on T {
  T tagged(dynamic tag) {
    if (tag is Iterable) {
      for (final t in tag) {
        tags.add(t.toString());
      }
    } else {
      tags.add(tag.toString());
    }
    return this;
  }

  T untag(dynamic tag) {
    if (tag is Iterable) {
      for (final t in tag) {
        tags.remove(t.toString());
      }
    } else {
      tags.remove(tag.toString());
    }
    return this;
  }

  bool hasTag(String tag) => tags.contains(tag);

  bool hasTags(Iterable<String> tag) => tags.containsAll(tag);
}

abstract class Comp implements JConvertibleProtocol {
  @JsonKey(ignore: true)
  Type get compType => runtimeType;

  const Comp();
}

mixin CompMixin<TComp extends Comp> {
  final Map<Type, List<TComp>> _components = {};
}

extension CompMixinX<TComp extends Comp> on CompMixin<TComp> {
  Iterable<TComp> iterateComps([List<Type>? filter]) sync* {
    for (final p in _components.entries) {
      if (filter == null || filter.contains(p.key)) {
        for (final comp in p.value) {
          yield comp;
        }
      }
    }
  }

  void addComp(TComp comp) {
    final type = comp.compType;
    final comps = _components[type];
    if (comps != null) {
      comps.add(comp);
    } else {
      _components[type] = [comp];
    }
  }

  T? getFirstComp<T extends TComp>() {
    return _components[T]?.firstOrNull as T?;
  }

  List<T> getCompsOf<T extends TComp>() {
    final comps = _components[T];
    if (comps == null) {
      return const [];
    } else {
      return comps.cast<T>();
    }
  }

  bool hasCompOf<T extends TComp>() {
    return _components.containsKey(T);
  }

  bool hasComp(Type compType) {
    return _components.containsKey(compType);
  }
}

abstract class RestorationProvider<T> {
  /// Return an restore id to save current place.
  dynamic getRestoreIdOf(covariant T place);

  /// Resolve [restoreId] to one of this places.
  T restoreById(dynamic restoreId);
}
