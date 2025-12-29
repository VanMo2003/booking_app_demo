class AccountResponse {
  String? id;
  String? username;
  String? role;
  bool? status;
  String? onCreate;
  String? onUpdate;

  AccountResponse({
    this.id,
    this.username,
    this.role,
    this.status,
    this.onCreate,
    this.onUpdate,
  });

  AccountResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    role = json['role'];
    status = json['status'];
    onCreate = json['onCreate'];
    onUpdate = json['onUpdate'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['role'] = role;
    data['status'] = status;
    data['onCreate'] = onCreate;
    data['onUpdate'] = onUpdate;
    return data;
  }
}
