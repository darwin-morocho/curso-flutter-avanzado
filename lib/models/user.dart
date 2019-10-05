class User {
  final String id, username, email;
  final DateTime createdAt, updatedAt;

  User({this.id, this.username, this.email, this.createdAt, this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt']);
    final updatedAt = DateTime.parse(json['updatedAt']);

    return User(
        id: json['_id'],
        username: json['username'],
        email: json['email'],
        createdAt: createdAt,
        updatedAt: updatedAt);
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": this.id,
      "email": this.email,
      "username": username,
      "createdAt": createdAt.toString(),
      "updatedAt": updatedAt.toString(),
    };
  }
}
