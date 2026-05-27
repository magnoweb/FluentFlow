class AuthResultDto {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final UserInfoDto user;

  AuthResultDto.fromJson(Map<String, dynamic> j)
    : accessToken = j['accessToken'] as String,
      refreshToken = j['refreshToken'] as String,
      expiresAt = DateTime.parse(j['expiresAt'] as String),
      user = UserInfoDto.fromJson(j['user'] as Map<String, dynamic>);
}

class UserInfoDto {
  final String id;
  final String name;
  final String email;
  final String userType;
  final String? profileImageBase64;

  UserInfoDto.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      email = j['email'] as String,
      userType = j['userType'] as String,
      profileImageBase64 = j['profileImageBase64'] as String?;
}
