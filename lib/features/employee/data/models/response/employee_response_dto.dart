class EmployeeResponseDto {
  final int id;
  final String pathImage;
  final String accountId;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth; // "2025-01-01"
  final String hometown;
  final int salary;
  final DateTime? onCreate;
  final DateTime? onUpdate;

  EmployeeResponseDto({
    required this.id,
    required this.pathImage,
    required this.accountId,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.hometown,
    required this.salary,
    this.onCreate,
    this.onUpdate,
  });

  factory EmployeeResponseDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

    return EmployeeResponseDto(
      id: (json['id'] ?? 0) as int,
      pathImage: (json['pathImage'] ?? '') as String,
      accountId: (json['accountId'] ?? '') as String,
      fullName: (json['fullName'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      dateOfBirth: (json['dateOfBirth'] ?? '') as String,
      hometown: (json['hometown'] ?? '') as String,
      salary: (json['salary'] ?? 0) as int,
      onCreate: parseDt(json['onCreate']),
      onUpdate: parseDt(json['onUpdate']),
    );
  }
}
