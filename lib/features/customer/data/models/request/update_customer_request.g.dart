// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCustomerRequest _$UpdateCustomerRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateCustomerRequest(
      pathImage: json['pathImage'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: json['gender'] as String,
      hometown: json['hometown'] as String,
    );

Map<String, dynamic> _$UpdateCustomerRequestToJson(
        UpdateCustomerRequest instance) =>
    <String, dynamic>{
      'pathImage': instance.pathImage,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'gender': instance.gender,
      'hometown': instance.hometown,
    };
