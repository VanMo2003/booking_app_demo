import 'package:json_annotation/json_annotation.dart';

part 'create_customer_request.g.dart';

@JsonSerializable()
class CreateCustomerRequest {
  final String pathImage;
  final String accountId;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String hometown;

  CreateCustomerRequest({
    required this.pathImage,
    required this.accountId,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.hometown,
  });

  factory CreateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCustomerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCustomerRequestToJson(this);
}
