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
}

mixin TagsMixin {
  @JsonKey(includeIfNull: false)
  final List<String> tags = [];
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

  T? tryGetFirstComp<T extends TComp>() {
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
