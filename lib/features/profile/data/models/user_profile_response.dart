class UserProfileResponse {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  UserProfileResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory UserProfileResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfileResponse(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}