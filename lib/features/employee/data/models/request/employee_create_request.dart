class EmployeeCreateRequest {
  final String pathImage;
  final String username;
  final String password;
  final int hotelId;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth; // yyyy-MM-dd
  final String hometown;
  final int salary;
  final int positionId;

  EmployeeCreateRequest({
    this.pathImage = '',
    required this.username,
    required this.password,
    required this.hotelId,
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
    "username": username,
    "password": password,
    "hotelId": hotelId,
    "fullName": fullName,
    "phoneNumber": phoneNumber,
    "gender": gender,
    "dateOfBirth": dateOfBirth,
    "hometown": hometown,
    "salary": salary,
    "positionId": positionId,
  };
}
