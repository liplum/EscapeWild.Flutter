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
  @JsonKey(toJson: directConvertFunc)
  final Map<Type, TComp> components = {};
}

extension CompMixinX<TComp extends Comp> on CompMixin<TComp> {
  void addCompOfType(Type type, TComp comp) {
    components[type] = comp;
  }

  void addCompOfExactType<T extends TComp>(T comp) {
    components[T] = comp;
  }

  void addCompOfExactTypes(Iterable<Type> types, TComp comp) {
    for (final type in types) {
      components[type] = comp;
    }
  }

  T? tryGetComp<T extends TComp>() {
    return components[T] as T?;
  }

  T getComp<T extends TComp>() {
    return components[T] as T;
  }

  bool hasComp<T extends TComp>() {
    return components.containsKey(T);
  }

  T? getCompOfTypes<T extends TComp>(Iterable<Type> types) {
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
  }
}
