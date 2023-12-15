// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      uid: json['uid'] as String,
      userName: json['userName'] as String? ?? 'unknown',
      imageUrl: json['imageUrl'] as String?,
      food: json['food'] as String?,
      numberOfPancakes: json['numberOfPancakes'] as int,
      followers: json['followers'] as int,
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'userName': instance.userName,
      'imageUrl': instance.imageUrl,
      'food': instance.food,
      'numberOfPancakes': instance.numberOfPancakes,
      'followers': instance.followers,
    };
