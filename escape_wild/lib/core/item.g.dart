// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ItemStackCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ItemStack(...).copyWith(id: 12, name: "My name")
  /// ````
  ItemStack call({
    Item? meta,
    int? id,
    int? mass,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfItemStack.copyWith(...)`.
class _$ItemStackCWProxyImpl implements _$ItemStackCWProxy {
  const _$ItemStackCWProxyImpl(this._value);

  final ItemStack _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ItemStack(...).copyWith(id: 12, name: "My name")
  /// ````
  ItemStack call({
    Object? meta = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? mass = const $CopyWithPlaceholder(),
  }) {
    return ItemStack(
      meta == const $CopyWithPlaceholder() || meta == null
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Item,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      mass: mass == const $CopyWithPlaceholder()
          ? _value.mass
          // ignore: cast_nullable_to_non_nullable
          : mass as int?,
    );
  }
}

extension $ItemStackCopyWith on ItemStack {
  /// Returns a callable class that can be used as follows: `instanceOfItemStack.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ItemStackCWProxy get copyWith => _$ItemStackCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemStack _$ItemStackFromJson(Map<String, dynamic> json) => ItemStack(
      Contents.getItemMetaByName(json['meta'] as String),
      id: (json['id'] as num?)?.toInt(),
      mass: (json['mass'] as num?)?.toInt(),
    )..extra = json['extra'] as Map<String, dynamic>?;

Map<String, dynamic> _$ItemStackToJson(ItemStack instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'id': instance.id,
      'meta': Item.getName(instance.meta),
      if (instance.mass case final value?) 'mass': value,
    };

ContainerItemStack _$ContainerItemStackFromJson(Map<String, dynamic> json) => ContainerItemStack(
      Contents.getItemMetaByName(json['meta'] as String),
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..inner = json['inner'] == null ? null : ItemStack.fromJson(json['inner'] as Map<String, dynamic>)
      ..mass = (json['mass'] as num?)?.toInt();

Map<String, dynamic> _$ContainerItemStackToJson(ContainerItemStack instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'meta': Item.getName(instance.meta),
      if (instance.inner case final value?) 'inner': value,
      if (instance.mass case final value?) 'mass': value,
    };
