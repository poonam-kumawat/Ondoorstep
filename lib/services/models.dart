import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

@JsonSerializable()
class AppUser{
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

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}