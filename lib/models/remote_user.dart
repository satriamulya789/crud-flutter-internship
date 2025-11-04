class RemoteUser {
  String? id;
  String? name;
  String? avatar;
  String? address;

  RemoteUser({this.id, this.name, this.avatar, this.address});

  factory RemoteUser.fromJson(Map<String, dynamic> json) {
    return RemoteUser(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar, 'address': address};
  }
}
