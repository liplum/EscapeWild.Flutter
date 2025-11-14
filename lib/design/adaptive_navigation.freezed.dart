// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adaptive_navigation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdaptiveNavigationItem {

 String get route; IconData get icon; IconData? get activeIcon; String get label;
/// Create a copy of AdaptiveNavigationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdaptiveNavigationItemCopyWith<AdaptiveNavigationItem> get copyWith => _$AdaptiveNavigationItemCopyWithImpl<AdaptiveNavigationItem>(this as AdaptiveNavigationItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdaptiveNavigationItem&&(identical(other.route, route) || other.route == route)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.activeIcon, activeIcon) || other.activeIcon == activeIcon)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,route,icon,activeIcon,label);

@override
String toString() {
  return 'AdaptiveNavigationItem(route: $route, icon: $icon, activeIcon: $activeIcon, label: $label)';
}


}

/// @nodoc
abstract mixin class $AdaptiveNavigationItemCopyWith<$Res>  {
  factory $AdaptiveNavigationItemCopyWith(AdaptiveNavigationItem value, $Res Function(AdaptiveNavigationItem) _then) = _$AdaptiveNavigationItemCopyWithImpl;
@useResult
$Res call({
 String route, IconData icon, IconData? activeIcon, String label
});




}
/// @nodoc
class _$AdaptiveNavigationItemCopyWithImpl<$Res>
    implements $AdaptiveNavigationItemCopyWith<$Res> {
  _$AdaptiveNavigationItemCopyWithImpl(this._self, this._then);

  final AdaptiveNavigationItem _self;
  final $Res Function(AdaptiveNavigationItem) _then;

/// Create a copy of AdaptiveNavigationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? route = null,Object? icon = null,Object? activeIcon = freezed,Object? label = null,}) {
  return _then(_self.copyWith(
route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,activeIcon: freezed == activeIcon ? _self.activeIcon : activeIcon // ignore: cast_nullable_to_non_nullable
as IconData?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdaptiveNavigationItem].
extension AdaptiveNavigationItemPatterns on AdaptiveNavigationItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdaptiveNavigationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdaptiveNavigationItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdaptiveNavigationItem value)  $default,){
final _that = this;
switch (_that) {
case _AdaptiveNavigationItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdaptiveNavigationItem value)?  $default,){
final _that = this;
switch (_that) {
case _AdaptiveNavigationItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String route,  IconData icon,  IconData? activeIcon,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdaptiveNavigationItem() when $default != null:
return $default(_that.route,_that.icon,_that.activeIcon,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String route,  IconData icon,  IconData? activeIcon,  String label)  $default,) {final _that = this;
switch (_that) {
case _AdaptiveNavigationItem():
return $default(_that.route,_that.icon,_that.activeIcon,_that.label);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String route,  IconData icon,  IconData? activeIcon,  String label)?  $default,) {final _that = this;
switch (_that) {
case _AdaptiveNavigationItem() when $default != null:
return $default(_that.route,_that.icon,_that.activeIcon,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _AdaptiveNavigationItem extends AdaptiveNavigationItem {
  const _AdaptiveNavigationItem({required this.route, required this.icon, this.activeIcon, required this.label}): super._();
  

@override final  String route;
@override final  IconData icon;
@override final  IconData? activeIcon;
@override final  String label;

/// Create a copy of AdaptiveNavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdaptiveNavigationItemCopyWith<_AdaptiveNavigationItem> get copyWith => __$AdaptiveNavigationItemCopyWithImpl<_AdaptiveNavigationItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdaptiveNavigationItem&&(identical(other.route, route) || other.route == route)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.activeIcon, activeIcon) || other.activeIcon == activeIcon)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,route,icon,activeIcon,label);

@override
String toString() {
  return 'AdaptiveNavigationItem(route: $route, icon: $icon, activeIcon: $activeIcon, label: $label)';
}


}

/// @nodoc
abstract mixin class _$AdaptiveNavigationItemCopyWith<$Res> implements $AdaptiveNavigationItemCopyWith<$Res> {
  factory _$AdaptiveNavigationItemCopyWith(_AdaptiveNavigationItem value, $Res Function(_AdaptiveNavigationItem) _then) = __$AdaptiveNavigationItemCopyWithImpl;
@override @useResult
$Res call({
 String route, IconData icon, IconData? activeIcon, String label
});




}
/// @nodoc
class __$AdaptiveNavigationItemCopyWithImpl<$Res>
    implements _$AdaptiveNavigationItemCopyWith<$Res> {
  __$AdaptiveNavigationItemCopyWithImpl(this._self, this._then);

  final _AdaptiveNavigationItem _self;
  final $Res Function(_AdaptiveNavigationItem) _then;

/// Create a copy of AdaptiveNavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? route = null,Object? icon = null,Object? activeIcon = freezed,Object? label = null,}) {
  return _then(_AdaptiveNavigationItem(
route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,activeIcon: freezed == activeIcon ? _self.activeIcon : activeIcon // ignore: cast_nullable_to_non_nullable
as IconData?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
