class EmployeeResponse {
  int? id;
  String? pathImage;
  String? username;
  String? accountId;
  String? fullName;
  String? phoneNumber;
  String? gender;
  String? dateOfBirth;
  String? hometown;
  int? salary;
  String? positionName;
  String? onCreate;
  String? onUpdate;

  EmployeeResponse(
      {this.id,
      this.pathImage,
      this.username,
      this.accountId,
      this.fullName,
      this.phoneNumber,
      this.gender,
      this.dateOfBirth,
      this.hometown,
      this.positionName,
      this.salary,
      this.onCreate,
      this.onUpdate});

  EmployeeResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pathImage = json['pathImage'];
    username = json['username'];
    accountId = json['accountId'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
    hometown = json['hometown'];
    positionName = json['positionName'];
    salary = json['salary'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pathImage'] = pathImage;
    data['username'] = username;
    data['accountId'] = accountId;
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    data['hometown'] = hometown;
    data['positionName'] = positionName;
    data['salary'] = salary;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
