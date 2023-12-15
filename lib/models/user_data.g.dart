// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      uid: json['uid'] as String,
      userName: json['userName'] as String? ?? 'unknown',
      imageUrl: json['imageUrl'] as String?,
      food: json['food'] as String,
      numberOfPancakes: json['numberOfPancakes'] as int,
      add: json['add'] as String,
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'userName': instance.userName,
      'imageUrl': instance.imageUrl,
      'food': instance.food,
      'numberOfPancakes': instance.numberOfPancakes,
      'add': instance.add,
    };
