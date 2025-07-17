class UserModel {
  final String id;
  final String email;
  final String password;
  final String role;
  final bool canEdit;
  final bool canDelete;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.canEdit,
    required this.canDelete,
  });

  // Factory method to create a UserModel from JSON (from API or Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
    );
  }

  // Convert UserModel to JSON (for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'canEdit': canEdit,
      'canDelete': canDelete,
    };
  }
}
