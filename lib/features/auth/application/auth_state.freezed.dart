// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 AuthStatus get status; User? get user;// Logged in user data
 String? get errorMessage;// Any error message during auth process
 bool get isLoading;// Indicate loading state
 AuthStep get authStep; int get otpAttempts;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.authStep, authStep) || other.authStep == authStep)&&(identical(other.otpAttempts, otpAttempts) || other.otpAttempts == otpAttempts));
}


@override
int get hashCode => Object.hash(runtimeType,status,user,errorMessage,isLoading,authStep,otpAttempts);

@override
String toString() {
  return 'AuthState(status: $status, user: $user, errorMessage: $errorMessage, isLoading: $isLoading, authStep: $authStep, otpAttempts: $otpAttempts)';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 AuthStatus status, User? user, String? errorMessage, bool isLoading, AuthStep authStep, int otpAttempts
});




}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? user = freezed,Object? errorMessage = freezed,Object? isLoading = null,Object? authStep = null,Object? otpAttempts = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,authStep: null == authStep ? _self.authStep : authStep // ignore: cast_nullable_to_non_nullable
as AuthStep,otpAttempts: null == otpAttempts ? _self.otpAttempts : otpAttempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _AuthState implements AuthState {
  const _AuthState({this.status = AuthStatus.unknown, this.user, this.errorMessage, this.isLoading = false, this.authStep = AuthStep.unknown, this.otpAttempts = 0});
  

@override@JsonKey() final  AuthStatus status;
@override final  User? user;
// Logged in user data
@override final  String? errorMessage;
// Any error message during auth process
@override@JsonKey() final  bool isLoading;
// Indicate loading state
@override@JsonKey() final  AuthStep authStep;
@override@JsonKey() final  int otpAttempts;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.authStep, authStep) || other.authStep == authStep)&&(identical(other.otpAttempts, otpAttempts) || other.otpAttempts == otpAttempts));
}


@override
int get hashCode => Object.hash(runtimeType,status,user,errorMessage,isLoading,authStep,otpAttempts);

@override
String toString() {
  return 'AuthState(status: $status, user: $user, errorMessage: $errorMessage, isLoading: $isLoading, authStep: $authStep, otpAttempts: $otpAttempts)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 AuthStatus status, User? user, String? errorMessage, bool isLoading, AuthStep authStep, int otpAttempts
});




}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? user = freezed,Object? errorMessage = freezed,Object? isLoading = null,Object? authStep = null,Object? otpAttempts = null,}) {
  return _then(_AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,authStep: null == authStep ? _self.authStep : authStep // ignore: cast_nullable_to_non_nullable
as AuthStep,otpAttempts: null == otpAttempts ? _self.otpAttempts : otpAttempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
