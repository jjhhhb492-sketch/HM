import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/video_service.dart';
import '../models/video_model.dart';
import '../models/user_model.dart';

// States
abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<VideoModel> videos;
  VideoLoaded(this.videos);
}

class VideoUploading extends VideoState {
  final double progress;
  VideoUploading(this.progress);
}

class VideoUploaded extends VideoState {}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
}

// Cubit
class VideoCubit extends Cubit<VideoState> {
  final VideoService _videoService;
  StreamSubscription<List<VideoModel>>? _feedSubscription;

  VideoCubit(this._videoService) : super(VideoInitial());

  // Listen to the Firestore live feed
  void loadFeed() {
    emit(VideoLoading());
    _feedSubscription?.cancel();
    _feedSubscription = _videoService.getVideosStream().listen(
      (videos) {
        emit(VideoLoaded(videos));
      },
      onError: (e) {
        emit(VideoError(e.toString()));
      },
    );
  }

  // Upload video with progress feedback
  Future<void> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required UserModel userDetails,
  }) async {
    emit(VideoUploading(0.0));
    try {
      await _videoService.uploadVideo(
        videoFile: videoFile,
        title: title,
        description: description,
        userId: userDetails.uid,
        username: userDetails.username,
        profilePictureUrl: userDetails.profilePictureUrl,
        onProgress: (progress) {
          emit(VideoUploading(progress));
        },
      );
      emit(VideoUploaded());
      loadFeed(); // Reload the feed
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }

  // Like / Unlike action
  Future<void> likeVideo(String videoId, String userId) async {
    try {
      await _videoService.likeVideo(videoId, userId);
    } catch (e) {
      // Silently handle or trigger error state if critical
    }
  }

  // Comment action
  Future<void> addComment(String videoId, String userId, String username, String text) async {
    try {
      await _videoService.addComment(videoId, userId, username, text);
    } catch (e) {
      // Silently handle
    }
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
