
class UserModel {
  final String uid;
  final String userName;
  final String email;
  final DateTime? modifiedDate;

  UserModel({
    required this.uid,
    required this.userName,
    required this.email,
    this.modifiedDate,
  });

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'userName': userName,
    'email': email,
    'modifiedDate': modifiedDate?.toIso8601String(),
  };

  // Create User object from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid']?.toString() ?? '',
    userName: json['userName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    modifiedDate:
        json['modifiedDate'] != null
            ? DateTime.parse(json['modifiedDate'])
            : null,
  );
}
