class Employee {
  final int id;
  final String username;
  final String pathImage;
  final String accountId;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth; // yyyy-MM-dd
  final String hometown;
  final int salary;
  final String positionName;
  final DateTime? onCreate;
  final DateTime? onUpdate;

  const Employee({
    required this.id,
    required this.username,
    required this.pathImage,
    required this.accountId,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.hometown,
    required this.salary,
    required this.positionName,
    this.onCreate,
    this.onUpdate,
  });
}
