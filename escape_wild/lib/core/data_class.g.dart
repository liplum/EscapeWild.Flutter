// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagMassEntry _$TagMassEntryFromJson(Map<String, dynamic> json) => TagMassEntry(
      (json['tags'] as List<dynamic>).map((e) => e as String),
      json['mass'] as int?,
    );

LazyItemStack _$LazyItemStackFromJson(Map<String, dynamic> json) =>
    LazyItemStack(
      NamedItemGetter.create(json['item'] as String),
      json['mass'] as int?,
    );
