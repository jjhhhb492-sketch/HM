import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/video_cubit.dart';
import '../models/video_model.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load videos on start
    context.read<VideoCubit>().loadFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fallback videos list if Firestore database is empty
  final List<VideoModel> _mockVideos = [
    VideoModel(
      id: 'mock1',
      url: 'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-light-1282-large.mp4',
      userId: 'mock_user_1',
      likes: ['user1', 'user2'],
      comments: [
        {'username': 'أحمد', 'comment': 'فيديو رائع جداً! 🔥', 'createdAt': DateTime.now()}
      ],
      username: 'libya_creator',
      description: 'أضواء النيون الجميلة في طرابلس 🇱🇾 #ليبيا #طرابلس #فن',
      profilePictureUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=libya_creator',
      createdAt: DateTime.now(),
    ),
    VideoModel(
      id: 'mock2',
      url: 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-47-large.mp4',
      userId: 'mock_user_2',
      likes: ['user3'],
      comments: [],
      username: 'benghazi_nature',
      description: 'جمال الطبيعة والربيع في الجبل الأخضر 🌸✨ #بنغازي #طبيعة',
      profilePictureUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=benghazi_nature',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Sub-pages based on Bottom Navigation Index
          IndexedStack(
            index: _currentTabIndex,
            children: [
              // Tab 0: Vertical Video Feed
              BlocBuilder<VideoCubit, VideoState>(
                builder: (context, state) {
                  List<VideoModel> displayList = [];
                  if (state is VideoLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.cyanAccent),
                    );
                  } else if (state is VideoLoaded) {
                    displayList = state.videos.isEmpty ? _mockVideos : state.videos;
                  } else {
                    displayList = _mockVideos; // Fallback
                  }

                  return PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      return VideoFeedItem(video: displayList[index]);
                    },
                  );
                },
              ),

              // Tab 1: Upload Screen
              const UploadScreen(),

              // Tab 2: Profile Screen
              const ProfileScreen(),
            ],
          ),

          // Translucent Bottom Overlay Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Feed Button
                    _buildNavItem(
                      icon: Icons.home_filled,
                      label: 'الرئيسية',
                      index: 0,
                    ),

                    // Add / Upload Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 1;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 3,
                              child: Container(
                                width: 44,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 3,
                              child: Container(
                                width: 44,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 40,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Profile Button
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'الملف الشخصي',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoFeedItem extends StatefulWidget {
  final VideoModel video;
  const VideoFeedItem({super.key, required this.video});

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  late AnimationController _discAnimationController;
  bool _showHeartAnimation = false;
  double _heartScale = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(true);
          _isPlaying = true;
          _discAnimationController.repeat();
        }
      });

    _discAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _discAnimationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
        _discAnimationController.stop();
      } else {
        _controller.play();
        _discAnimationController.repeat();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _onDoubleTap() {
    setState(() {
      _showHeartAnimation = true;
      _heartScale = 1.0;
    });

    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<VideoCubit>().likeVideo(widget.video.id, authState.userDetails.uid);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showHeartAnimation = false;
          _heartScale = 0.0;
        });
      }
    });
  }

  void _showCommentsBottomSheet() {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'التعليقات (${widget.video.comments.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: widget.video.comments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text(
                              'لا توجد تعليقات بعد. كن أول من يعلق!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.video.comments.length,
                            itemBuilder: (context, index) {
                              final comment = widget.video.comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    'https://api.dicebear.com/7.x/adventurer/png?seed=${comment['username']}',
                                  ),
                                ),
                                title: Text(
                                  comment['username'] ?? 'Anonymous',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  textAlign: TextAlign.right,
                                ),
                                subtitle: Text(
                                  comment['comment'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.cyanAccent),
                        onPressed: () {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            final authState = context.read<AuthCubit>().state;
                            if (authState is Authenticated) {
                              context.read<VideoCubit>().addComment(
                                widget.video.id,
                                authState.userDetails.uid,
                                authState.userDetails.username,
                                text,
                              );
                              setModalState(() {
                                widget.video.comments.insert(0, {
                                  'username': authState.userDetails.username,
                                  'comment': text,
                                });
                              });
                              commentController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('يرجى تسجيل الدخول أولاً للتعليق')),
                              );
                            }
                          }
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'أضف تعليقاً...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authState = context.watch<AuthCubit>().state;
    final currentUserId = authState is Authenticated ? authState.userDetails.uid : '';
    final isLiked = widget.video.likes.contains(currentUserId);

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Video Player
          _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  ),
                ),

          // Translucent gradient overlay for readability of labels
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Double Tap Heart Animation overlay
          AnimatedOpacity(
            opacity: _showHeartAnimation ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedScale(
              scale: _heartScale,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 110,
              ),
            ),
          ),

          // Right Side Action Buttons
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Creator Profile Avatar
                GestureDetector(
                  onTap: () {
                    // Navigate or show creator profile
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(widget.video.profilePictureUrl),
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Like Button
                GestureDetector(
                  onTap: () {
                    if (currentUserId.isNotEmpty) {
                      context.read<VideoCubit>().likeVideo(widget.video.id, currentUserId);
                      setState(() {
                        if (isLiked) {
                          widget.video.likes.remove(currentUserId);
                        } else {
                          widget.video.likes.add(currentUserId);
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً للإعجاب بالفيديو')),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.redAccent : Colors.white,
                        size: 38,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.video.likes.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Comments Button
                GestureDetector(
                  onTap: _showCommentsBottomSheet,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.comment_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.video.comments.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Share Button
                GestureDetector(
                  onTap: () {
                    // Trigger native share dialog simulation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ رابط الفيديو بنجاح! 🔗', textAlign: TextAlign.right),
                        backgroundColor: Colors.cyan,
                      ),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مشاركة',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Rotating Album Disk
                AnimatedBuilder(
                  animation: _discAnimationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _discAnimationController.value * 2 * pi,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.black54, Colors.grey, Colors.black87],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(widget.video.profilePictureUrl),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Left Bottom Description overlay
          Positioned(
            left: 16,
            bottom: 84,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  '@${widget.video.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                // Description/Tags
                Text(
                  widget.video.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Music scrolling track
                const Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'الصوت الأصلي - HM ليبيا للإنتاج',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Large Play/Pause Indicator if paused
          if (!_isPlaying)
            Positioned(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
