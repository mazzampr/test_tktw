class DataUser {
  final List<User> data;

  DataUser({required this.data});

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
    data: List.from(json['data'].map((user) => User.fromJson(user)))
  );
}


class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        avatar: json['avatar'],
      );
}
