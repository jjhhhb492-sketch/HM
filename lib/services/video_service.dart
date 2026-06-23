import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video_model.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream of all videos (Feed) sorted by newest first
  Stream<List<VideoModel>> getVideosStream() {
    return _firestore
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VideoModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Upload video file to Firebase Storage and metadata to Firestore
  Future<void> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required String userId,
    required String username,
    required String profilePictureUrl,
    Function(double progress)? onProgress,
  }) async {
    try {
      final String videoId = _firestore.collection('videos').doc().id;
      final Reference storageRef = _storage.ref().child('videos/$videoId.mp4');

      // Upload file with progress tracking
      final UploadTask uploadTask = storageRef.putFile(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress(progress);
        }
      });

      final TaskSnapshot completedTask = await uploadTask;
      final String videoUrl = await completedTask.ref.getDownloadURL();

      // Create video record in Firestore
      final VideoModel video = VideoModel(
        id: videoId,
        url: videoUrl,
        userId: userId,
        likes: [],
        comments: [],
        username: username,
        description: '$title\n$description',
        profilePictureUrl: profilePictureUrl,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('videos').doc(videoId).set(video.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Toggle Like: Add or remove user ID from the video's likes array
  Future<void> likeVideo(String videoId, String userId) async {
    try {
      final DocumentReference videoRef = _firestore.collection('videos').doc(videoId);
      final DocumentSnapshot doc = await videoRef.get();

      if (doc.exists) {
        final List<dynamic> likes = doc.get('likes') ?? [];
        if (likes.contains(userId)) {
          // Unlike
          await videoRef.update({
            'likes': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Like
          await videoRef.update({
            'likes': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch videos uploaded by a specific user (for Profile tab)
  Future<List<VideoModel>> getUserVideos(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('videos')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return VideoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add Comment to video
  Future<void> addComment(String videoId, String userId, String username, String text) async {
    try {
      final DocumentReference videoRef = _firestore.collection('videos').doc(videoId);
      final Map<String, dynamic> comment = {
        'userId': userId,
        'username': username,
        'comment': text,
        'createdAt': Timestamp.now(),
      };
      await videoRef.update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    } catch (e) {
      rethrow;
    }
  }
}
