import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final VideoService _videoService = VideoService();
  List<VideoModel> _userVideos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserVideos();
  }

  Future<void> _loadUserVideos() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      setState(() {
        _isLoading = true;
      });
      try {
        final videos = await _videoService.getUserVideos(authState.userDetails.uid);
        setState(() {
          _userVideos = videos;
        });
      } catch (e) {
        // Handle error or use mock
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Mock thumbnails to show in profile grid if user has no uploads yet
  final List<String> _mockThumbnails = [
    'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&q=80',
    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=400&q=80',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'الرجاء تسجيل الدخول لعرض ملفك الشخصي',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        }

        final user = state.userDetails;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: () {
                _showLogoutConfirmDialog(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.cyanAccent),
                onPressed: _loadUserVideos,
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Avatar and Bio Details
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.cyanAccent, Colors.purpleAccent],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.profilePictureUrl),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '@${user.username}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 16),

                // User Bio Text Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Counter Layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol('متابَعين', '124'),
                    _buildStatCol('متابِعين', '12.5K'),
                    _buildStatCol('تسجيلات الإعجاب', '84.2K'),
                  ],
                ),
                const SizedBox(height: 24),

                // Divider line
                Container(
                  height: 1,
                  color: Colors.grey[900],
                ),

                // Video Grid List Icon Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grid_on_rounded, color: Colors.cyanAccent, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'الفيديوهات الخاصة بي',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      )
                    ],
                  ),
                ),

                // Displaying Videos Grid
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: Colors.cyanAccent),
                        ),
                      )
                    : _userVideos.isEmpty
                        ? _buildMockGrid() // fallback mockup grid
                        : _buildVideosGrid(),

                const SizedBox(height: 80), // spacer for bottom nav bar padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCol(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 0.75,
      ),
      itemCount: _userVideos.length,
      itemBuilder: (context, index) {
        final video = _userVideos[index];
        return Container(
          color: Colors.grey[950],
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Display profile item placeholder image (video play icon overlay)
              Image.network(
                video.profilePictureUrl, // using user avatar as simple visual color context
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black45,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${video.likes.length} إعجاب',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMockGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: _mockThumbnails.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[950],
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _mockThumbnails[index],
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black30,
              ),
              const Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '1.5K',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white), textAlign: TextAlign.right),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟', style: TextStyle(color: Colors.grey), textAlign: TextAlign.right),
          actions: [
            TextButton(
              child: const Text('إلغاء', style: TextStyle(color: Colors.cyanAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('تسجيل خروج', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logoutUser();
              },
            ),
          ],
        );
      },
    );
  }
}
