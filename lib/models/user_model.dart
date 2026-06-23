class UserModel {
  final String uid;
  final String email;
  final String username;
  final String profilePictureUrl;
  final String bio;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.profilePictureUrl,
    required this.bio,
  });

  // Convert UserModel to a map to store in Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
    };
  }

  // Create a UserModel from a Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      bio: map['bio'] ?? '',
    );
  }

  // Create a copy of the model with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? profilePictureUrl,
    String? bio,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
    );
  }
}
