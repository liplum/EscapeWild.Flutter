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
  Map<String, dynamic> tags = {};
}

abstract class Comp implements JConvertibleProtocol {
  const Comp();
}

mixin CompMixin<TComp extends Comp> {
  final Map<Type, List<TComp>> _components = {};
}

extension CompMixinX<TComp extends Comp> on CompMixin<TComp> {
  void addCompOfType(Type type, TComp comp) {
    final comps = _components[type];
    if (comps != null) {
      comps.add(comp);
    } else {
      _components[type] = [comp];
    }
  }

  void addCompOfExactType<T extends TComp>(T comp) {
    addCompOfType(T, comp);
  }

  void addCompOfTypes(Iterable<Type> types, TComp comp) {
    for (final type in types) {
      addCompOfType(type, comp);
    }
  }

  T? tryGetFirstComp<T extends TComp>() {
    return _components[T]?.firstOrNull as T?;
  }

  bool hasComp<T extends TComp>() {
    return _components.containsKey(T);
  }

/* T? getCompOfTypes<T extends TComp>(Iterable<Type> types) {
    TComp? comp;
    for (final type in types) {
      final found = components[type];
      if (found == null || found is! T) {
        return null;
      } else {
        comp = found;
      }
    }
    return comp as T?;
  }*/
}
