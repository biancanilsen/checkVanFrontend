import 'package:json_annotation/json_annotation.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class DriverModel {
  final int id;
  final String driverName;
  final String email;

  DriverModel({
    required this.id,
    required this.driverName,
    required this.email,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);
  Map<String, dynamic> toJson() => _$DriverModelToJson(this);
}
