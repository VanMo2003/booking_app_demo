class EmployeeResponse {
  int? id;
  String? pathImage;
  String? fullName;
  String? phoneNumber;
  String? gender;
  String? dateOfBirth;
  String? hometown;
  int? salary;
  String? onCreate;
  String? onUpdate;

  EmployeeResponse(
      {this.id,
      this.pathImage,
      this.fullName,
      this.phoneNumber,
      this.gender,
      this.dateOfBirth,
      this.hometown,
      this.salary,
      this.onCreate,
      this.onUpdate});

  EmployeeResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pathImage = json['pathImage'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
    hometown = json['hometown'];
    salary = json['salary'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pathImage'] = pathImage;
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    data['hometown'] = hometown;
    data['salary'] = salary;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
