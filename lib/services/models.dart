import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

@JsonSerializable()
class AppUser {
  late final String id;
  final String name;
  final String email;
  final String phoneNumber;

  AppUser({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}

@JsonSerializable()
class Bookorder {
  late final String id;
  final String otp;
  final String userId;
  final Location pickup;
  final Location dropoff;
  final String status;
  final String createdAt;

  Bookorder({
    required this.id,
    required this.otp,
    required this.userId,
    required this.pickup,
    required this.dropoff,
    required this.status,
    required this.createdAt,
  });

  factory Bookorder.fromJson(Map<String, dynamic> json) =>
      _$BookorderFromJson(json);
  Map<String, dynamic> toJson() => _$BookorderToJson(this);
}

@JsonSerializable()
class Location {
  final double latitute;
  final double longitude;

  Location({
    required this.latitute,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
