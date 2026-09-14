import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.pathImage,
    this.accountId,
    this.username,
    this.gender = '',
    this.hometown = '',
  });

  final int id;
  final String fullName;
  final String phoneNumber;
  final String? pathImage;

  /// `null` với khách vãng lai tạo tại quầy.
  final String? accountId;
  final String? username;
  final String gender;
  final String hometown;

  bool get isWalkIn => accountId == null || accountId!.isEmpty;

  @override
  List<Object?> get props =>
      [id, fullName, phoneNumber, pathImage, accountId, username, gender, hometown];
}
