class User {
  User({
    required this.userId,
    required this.sessionId,
    required this.userName,
    required this.email,
    required this.nickname,
  });

  factory User.fromMap(Map map) {
    return User(
      userId: map['user_id'],
      sessionId: map['session_id'],
      userName: map['user_name'],
      email: map['email'],
      nickname: map['nickname'],
    );
  }

  final String userId;
  final String sessionId;
  final String userName;
  final String email;
  String nickname;
}
