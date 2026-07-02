class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.phone = '',
    this.address = '',
    this.avatarUrl = '',
  });

  String get name => fullName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
