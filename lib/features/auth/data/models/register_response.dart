class RegisterResponse {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  RegisterResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory RegisterResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegisterResponse(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );
  }
}