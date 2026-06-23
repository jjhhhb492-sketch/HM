import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String url;
  final String userId;
  final List<String> likes;
  final List<Map<String, dynamic>> comments;
  final String username;
  final String description;
  final String profilePictureUrl;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.url,
    required this.userId,
    required this.likes,
    required this.comments,
    required this.username,
    required this.description,
    required this.profilePictureUrl,
    required this.createdAt,
  });

  // Convert VideoModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'userId': userId,
      'likes': likes,
      'comments': comments,
      'username': username,
      'description': description,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create VideoModel from Firestore document snapshot/map
  factory VideoModel.fromMap(Map<String, dynamic> map, String docId) {
    return VideoModel(
      id: docId,
      url: map['url'] ?? '',
      userId: map['userId'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
      username: map['username'] ?? 'Anonymous',
      description: map['description'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
