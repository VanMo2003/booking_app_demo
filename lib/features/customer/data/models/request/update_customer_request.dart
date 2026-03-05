import 'package:json_annotation/json_annotation.dart';

part 'update_customer_request.g.dart';

@JsonSerializable()
class UpdateCustomerRequest {
  final String pathImage;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String hometown;

  UpdateCustomerRequest({
    required this.pathImage,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.hometown,
  });

  factory UpdateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCustomerRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCustomerRequestToJson(this);
}
