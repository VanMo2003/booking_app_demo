// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomerRequest _$CreateCustomerRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCustomerRequest(
      pathImage: json['pathImage'] as String,
      accountId: json['accountId'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      hometown: json['hometown'] as String,
    );

Map<String, dynamic> _$CreateCustomerRequestToJson(
        CreateCustomerRequest instance) =>
    <String, dynamic>{
      'pathImage': instance.pathImage,
      'accountId': instance.accountId,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'gender': instance.gender,
      'hometown': instance.hometown,
    };
