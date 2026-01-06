class EmployeeUpdateRequest {
  final String pathImage;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String hometown;
  final int salary;
  final int positionId;

  EmployeeUpdateRequest({
    required this.pathImage,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.hometown,
    required this.salary,
    required this.positionId,
  });

  Map<String, dynamic> toJson() => {
    "pathImage": pathImage,
    "fullName": fullName,
    "phoneNumber": phoneNumber,
    "gender": gender,
    "dateOfBirth": dateOfBirth,
    "hometown": hometown,
    "salary": salary,
    "positionId": positionId,
  };
}
