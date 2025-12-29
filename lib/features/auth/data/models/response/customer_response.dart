class CustomerResponse {
  int? id;
  String? pathImage;
  String? accountId;
  String? username;
  String? fullName;
  String? phoneNumber;
  String? gender;
  String? hometown;
  String? onCreate;
  String? onUpdate;

  CustomerResponse(
      {this.id,
      this.pathImage,
      this.accountId,
      this.username,
      this.fullName,
      this.phoneNumber,
      this.gender,
      this.hometown,
      this.onCreate,
      this.onUpdate});

  CustomerResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pathImage = json['pathImage'];
    accountId = json['accountId'];
    username = json['username'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    gender = json['gender'];
    hometown = json['hometown'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pathImage'] = pathImage;
    data['accountId'] = accountId;
    data['username'] = username;
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['gender'] = gender;
    data['hometown'] = hometown;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
