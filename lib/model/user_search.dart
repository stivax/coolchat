class UserSearch {
  int id;
  String userName;
  String avatar;
  String createdAt;

  UserSearch(
      {required this.id,
      required this.userName,
      required this.avatar,
      required this.createdAt});

  static List<UserSearch> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return UserSearch(
        id: json['id'],
        userName: json['user_name'],
        avatar: json['avatar'],
        createdAt: json['created_at'],
      );
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_name'] = userName;
    data['avatar'] = avatar;
    data['created_at'] = createdAt;
    return data;
  }
}
