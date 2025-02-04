import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class Comp implements JConvertibleProtocol {
  String get name;

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  bool hasComps(Iterable<Type> compTypes) {
    for (final compType in compTypes) {
      if (!_components.containsKey(compType)) {
        return false;
      }
    }
    return true;
  }
}
