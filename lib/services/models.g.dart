// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
    };

Bookorder _$BookorderFromJson(Map<String, dynamic> json) => Bookorder(
      id: json['id'] as String,
      otp: json['otp'] as String,
      userId: json['userId'] as String,
      pickup: Location.fromJson(json['pickup'] as Map<String, dynamic>),
      dropoff: Location.fromJson(json['dropoff'] as Map<String, dynamic>),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$BookorderToJson(Bookorder instance) => <String, dynamic>{
      'id': instance.id,
      'otp': instance.otp,
      'userId': instance.userId,
      'pickup': instance.pickup,
      'dropoff': instance.dropoff,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      latitute: (json['latitute'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'latitute': instance.latitute,
      'longitude': instance.longitude,
    };
