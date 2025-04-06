// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {

 bool get isLoading; bool get isEditing; bool get isSaving; String? get errorMessage; Map<String, dynamic> get profileData; String? get id;// Changed from profileId
 String? get seekerId; bool get dataLoaded; bool get dataLoadAttempted;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.profileData, profileData)&&(identical(other.id, id) || other.id == id)&&(identical(other.seekerId, seekerId) || other.seekerId == seekerId)&&(identical(other.dataLoaded, dataLoaded) || other.dataLoaded == dataLoaded)&&(identical(other.dataLoadAttempted, dataLoadAttempted) || other.dataLoadAttempted == dataLoadAttempted));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isEditing,isSaving,errorMessage,const DeepCollectionEquality().hash(profileData),id,seekerId,dataLoaded,dataLoadAttempted);

@override
String toString() {
  return 'ProfileState(isLoading: $isLoading, isEditing: $isEditing, isSaving: $isSaving, errorMessage: $errorMessage, profileData: $profileData, id: $id, seekerId: $seekerId, dataLoaded: $dataLoaded, dataLoadAttempted: $dataLoadAttempted)';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isEditing, bool isSaving, String? errorMessage, Map<String, dynamic> profileData, String? id, String? seekerId, bool dataLoaded, bool dataLoadAttempted
});




}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isEditing = null,Object? isSaving = null,Object? errorMessage = freezed,Object? profileData = null,Object? id = freezed,Object? seekerId = freezed,Object? dataLoaded = null,Object? dataLoadAttempted = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,profileData: null == profileData ? _self.profileData : profileData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,seekerId: freezed == seekerId ? _self.seekerId : seekerId // ignore: cast_nullable_to_non_nullable
as String?,dataLoaded: null == dataLoaded ? _self.dataLoaded : dataLoaded // ignore: cast_nullable_to_non_nullable
as bool,dataLoadAttempted: null == dataLoadAttempted ? _self.dataLoadAttempted : dataLoadAttempted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _ProfileState implements ProfileState {
  const _ProfileState({this.isLoading = true, this.isEditing = false, this.isSaving = false, this.errorMessage, final  Map<String, dynamic> profileData = const <String, dynamic>{}, this.id, this.seekerId, this.dataLoaded = false, this.dataLoadAttempted = false}): _profileData = profileData;
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isEditing;
@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
 final  Map<String, dynamic> _profileData;
@override@JsonKey() Map<String, dynamic> get profileData {
  if (_profileData is EqualUnmodifiableMapView) return _profileData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_profileData);
}

@override final  String? id;
// Changed from profileId
@override final  String? seekerId;
@override@JsonKey() final  bool dataLoaded;
@override@JsonKey() final  bool dataLoadAttempted;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._profileData, _profileData)&&(identical(other.id, id) || other.id == id)&&(identical(other.seekerId, seekerId) || other.seekerId == seekerId)&&(identical(other.dataLoaded, dataLoaded) || other.dataLoaded == dataLoaded)&&(identical(other.dataLoadAttempted, dataLoadAttempted) || other.dataLoadAttempted == dataLoadAttempted));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isEditing,isSaving,errorMessage,const DeepCollectionEquality().hash(_profileData),id,seekerId,dataLoaded,dataLoadAttempted);

@override
String toString() {
  return 'ProfileState(isLoading: $isLoading, isEditing: $isEditing, isSaving: $isSaving, errorMessage: $errorMessage, profileData: $profileData, id: $id, seekerId: $seekerId, dataLoaded: $dataLoaded, dataLoadAttempted: $dataLoadAttempted)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isEditing, bool isSaving, String? errorMessage, Map<String, dynamic> profileData, String? id, String? seekerId, bool dataLoaded, bool dataLoadAttempted
});




}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isEditing = null,Object? isSaving = null,Object? errorMessage = freezed,Object? profileData = null,Object? id = freezed,Object? seekerId = freezed,Object? dataLoaded = null,Object? dataLoadAttempted = null,}) {
  return _then(_ProfileState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,profileData: null == profileData ? _self._profileData : profileData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,seekerId: freezed == seekerId ? _self.seekerId : seekerId // ignore: cast_nullable_to_non_nullable
as String?,dataLoaded: null == dataLoaded ? _self.dataLoaded : dataLoaded // ignore: cast_nullable_to_non_nullable
as bool,dataLoadAttempted: null == dataLoadAttempted ? _self.dataLoadAttempted : dataLoadAttempted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
