class LoginHistoryModel {
  final String email;
  final String loginTime;
  final String title;

  const LoginHistoryModel({
    required this.email,
    required this.loginTime,
    required this.title,
  });

  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
    return LoginHistoryModel(
      email: json['email']?.toString() ?? '',
      loginTime: json['loginTime']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'loginTime': loginTime, 'title': title};
  }
}
