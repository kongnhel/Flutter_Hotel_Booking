class UserModel {
  final String id;
  final String email;
  final String role;
  final bool canEdit;
  final bool canDelete;
  final String? firstName; // Added firstName
  final String? lastName; // Added lastName
  final String? phone;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.canEdit,
    required this.canDelete,
    this.firstName, // Added to constructor
    this.lastName, // Added to constructor
    this.phone = '',
    this.profileImage = '',
  });

  /// Creates a UserModel instance from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      canEdit: json['canEdit'] as bool? ?? false,
      canDelete: json['canDelete'] as bool? ?? false,
      firstName: json['firstName'] as String?, // Parse firstName
      lastName: json['lastName'] as String?, // Parse lastName
      phone: json['phone'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
    );
  }

  /// Converts this UserModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'canEdit': canEdit,
      'canDelete': canDelete,
      'firstName': firstName, // Include firstName
      'lastName': lastName, // Include lastName
      'phone': phone,
      'profileImage': profileImage,
    };
  }

  /// Creates a new UserModel instance with updated values.
  ///
  /// Provides an easy way to create a new object with some properties
  /// changed while keeping others the same.
  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    bool? canEdit,
    bool? canDelete,
    String? firstName, // Now correctly optional parameter for copyWith
    String? lastName, // Now correctly optional parameter for copyWith
    String? phone,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      firstName:
          firstName ?? this.firstName, // Assign new firstName or keep old
      lastName: lastName ?? this.lastName, // Assign new lastName or keep old
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: $role, canEdit: $canEdit, canDelete: $canDelete, firstName: $firstName, lastName: $lastName, phone: $phone, profileImage: $profileImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.role == role &&
        other.canEdit == canEdit &&
        other.canDelete == canDelete &&
        other.firstName == firstName && // Compare firstName
        other.lastName == lastName && // Compare lastName
        other.phone == phone &&
        other.profileImage == profileImage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        role.hashCode ^
        canEdit.hashCode ^
        canDelete.hashCode ^
        firstName.hashCode ^ // Include firstName in hashCode
        lastName.hashCode ^ // Include lastName in hashCode
        phone.hashCode ^
        profileImage.hashCode;
  }
}
